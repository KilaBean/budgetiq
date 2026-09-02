// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/sync/pending_op.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_data_source.dart';
import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';

/// Offline-first [BudgetRepository].
///
/// Reads prefer the network (refreshing the Hive cache) and fall back to cache
/// offline. Allocation writes apply to the cached month-budget optimistically
/// and enqueue outbox ops, so budgeting works offline and syncs later.
///
/// A month's budget uses one client-generated id; each allocation reuses the
/// existing id for its category (update) or gets a new one (insert), so replays
/// are idempotent upserts by primary key.
class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl({
    required BudgetRemoteDataSource remote,
    required BudgetLocalDataSource local,
    required SyncQueue queue,
    required bool Function() isOnline,
    required String currencyCode,
    required String? Function() currentUserId,
    required String? Function(String categoryId) resolveCategoryName,
    void Function()? onEnqueued,
  }) : _remote = remote,
       _local = local,
       _queue = queue,
       _isOnline = isOnline,
       _currency = currencyCode,
       _currentUserId = currentUserId,
       _resolveCategoryName = resolveCategoryName,
       _onEnqueued = onEnqueued;

  final BudgetRemoteDataSource _remote;
  final BudgetLocalDataSource _local;
  final SyncQueue _queue;
  final bool Function() _isOnline;
  final String _currency;
  final String? Function() _currentUserId;
  final String? Function(String) _resolveCategoryName;
  final void Function()? _onEnqueued;

  static const _uuid = Uuid();

  String _periodStart(Month month) =>
      '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}-01';

  @override
  Future<Budget?> getBudget(Month month) async {
    final period = _periodStart(month);
    if (!_isOnline()) {
      final cached = _local.read(period);
      return cached == null ? null : BudgetModel.fromJson(cached, _currency);
    }
    try {
      final row = await _remote.fetchBudget(period);
      await _local.write(period, row);
      return row == null ? null : BudgetModel.fromJson(row, _currency);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      final cached = _local.read(period);
      if (cached != null) return BudgetModel.fromJson(cached, _currency);
      throw const NetworkFailure('Could not load budget.');
    }
  }

  @override
  Future<Budget> setAllocation({
    required Month month,
    required String expenseCategoryId,
    required Money amount,
  }) async {
    final period = _periodStart(month);

    // Ensure a (cached) budget exists for the month.
    var budget = _local.read(period);
    if (budget == null) {
      final budgetId = _uuid.v4();
      budget = {
        'id': budgetId,
        'period_start': period,
        'currency_code': _currency,
        'budget_categories': <dynamic>[],
      };
      await _enqueue(
        SyncOpType.insert,
        table: 'budgets',
        recordId: budgetId,
        data: {
          'id': budgetId,
          'user_id': _requireUser(),
          'period_start': period,
        },
      );
    }
    final budgetId = budget['id'] as String;

    final allocations = List<Map<String, dynamic>>.from(
      budget['budget_categories'] as List,
    );
    final index = allocations.indexWhere(
      (a) => a['expense_category_id'] == expenseCategoryId,
    );
    final isUpdate = index >= 0;
    final allocationId = isUpdate
        ? allocations[index]['id'] as String
        : _uuid.v4();

    // Server version this edit is based on, so a concurrent change elsewhere
    // wins instead of being silently overwritten on replay.
    final existing = isUpdate ? allocations[index] : null;

    final row = {
      'id': allocationId,
      'expense_category_id': expenseCategoryId,
      'allocated_amount': amount.major,
      if (existing?['updated_at'] != null)
        'updated_at': existing!['updated_at'],
      'expense_categories': {'name': _resolveCategoryName(expenseCategoryId)},
    };
    if (isUpdate) {
      allocations[index] = row;
    } else {
      allocations.add(row);
    }
    budget['budget_categories'] = allocations;
    await _local.write(period, budget);

    await _enqueue(
      isUpdate ? SyncOpType.update : SyncOpType.insert,
      table: 'budget_categories',
      recordId: allocationId,
      data: isUpdate
          ? {'allocated_amount': amount.major}
          : {
              'id': allocationId,
              'budget_id': budgetId,
              'expense_category_id': expenseCategoryId,
              'allocated_amount': amount.major,
            },
      baseUpdatedAt: isUpdate ? baseUpdatedAtOf(existing) : null,
    );
    return BudgetModel.fromJson(budget, _currency);
  }

  @override
  Future<void> removeAllocation(BudgetAllocation allocation) async {
    // There is exactly one cached budget per month; find the one containing it.
    final period = _periodContaining(allocation.id);
    if (period != null) {
      final budget = _local.read(period)!;
      final allocations = (budget['budget_categories'] as List).where((a) {
        return (a as Map)['id'] != allocation.id;
      }).toList();
      budget['budget_categories'] = allocations;
      await _local.write(period, budget);
    }
    await _enqueue(
      SyncOpType.delete,
      table: 'budget_categories',
      recordId: allocation.id,
      data: const {},
    );
  }

  // --- helpers -------------------------------------------------------------

  /// Period key of the cached budget that holds [allocationId], if any.
  String? _periodContaining(String allocationId) {
    final period = _periodStart(Month.current());
    final budget = _local.read(period);
    if (budget == null) return null;
    final has = (budget['budget_categories'] as List).any(
      (a) => (a as Map)['id'] == allocationId,
    );
    return has ? period : null;
  }

  Future<void> _enqueue(
    SyncOpType type, {
    required String table,
    required String recordId,
    required Map<String, dynamic> data,
    DateTime? baseUpdatedAt,
  }) async {
    await _queue.enqueue(
      PendingOp(
        id: _uuid.v4(),
        table: table,
        type: type,
        recordId: recordId,
        data: data,
        createdAt: DateTime.now(),
        baseUpdatedAt: baseUpdatedAt,
      ),
    );
    _onEnqueued?.call();
  }

  String _requireUser() {
    final id = _currentUserId();
    if (id == null) throw const AuthFailure('Not authenticated.');
    return id;
  }
}
