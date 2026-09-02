// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/sync/pending_op.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../shared/domain/money.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_data_source.dart';
import '../datasources/goal_remote_data_source.dart';
import '../models/goal_model.dart';

/// Offline-first [GoalRepository].
///
/// Reads prefer the network (refreshing the cache) and fall back to cache
/// offline. Goal and contribution writes apply optimistically to the cache and
/// enqueue outbox ops, so they work offline and sync later.
class GoalRepositoryImpl implements GoalRepository {
  GoalRepositoryImpl({
    required GoalRemoteDataSource remote,
    required GoalLocalDataSource local,
    required SyncQueue queue,
    required bool Function() isOnline,
    required String? Function() currentUserId,
    required String currencyCode,
    void Function()? onEnqueued,
  }) : _remote = remote,
       _local = local,
       _queue = queue,
       _isOnline = isOnline,
       _currentUserId = currentUserId,
       _currency = currencyCode,
       _onEnqueued = onEnqueued;

  final GoalRemoteDataSource _remote;
  final GoalLocalDataSource _local;
  final SyncQueue _queue;
  final bool Function() _isOnline;
  final String? Function() _currentUserId;
  final String _currency;
  final void Function()? _onEnqueued;

  static const _uuid = Uuid();

  @override
  Future<List<Goal>> getGoals() async {
    if (!_isOnline()) {
      return _mapRows(_local.read());
    }
    try {
      final rows = await _remote.fetchGoals();
      await _local.write(rows);
      return _mapRows(rows);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      final cached = _local.read();
      if (cached.isNotEmpty) return _mapRows(cached);
      throw const NetworkFailure('Could not load goals.');
    }
  }

  List<Goal> _mapRows(List<Map<String, dynamic>> rows) =>
      rows.map((r) => GoalModel.fromJson(r, _currency)).toList();

  @override
  Future<Goal> createGoal({
    required String name,
    required Money targetAmount,
    DateTime? targetDate,
  }) async {
    final id = _uuid.v4();
    final row = <String, dynamic>{
      'id': id,
      'name': name.trim(),
      'target_amount': targetAmount.major,
      'currency_code': targetAmount.currencyCode,
      'target_date': targetDate == null ? null : _dateOnly(targetDate),
      'status': 'active',
      'goal_contributions': <dynamic>[],
    };
    await _local.write([row, ..._local.read()]);
    await _enqueue(
      SyncOpType.insert,
      table: 'goals',
      recordId: id,
      data: {
        'id': id,
        'user_id': _requireUser(),
        'name': row['name'],
        'target_amount': row['target_amount'],
        'currency_code': row['currency_code'],
        'target_date': row['target_date'],
      },
    );
    return GoalModel.fromJson(row, _currency);
  }

  @override
  Future<void> deleteGoal(Goal goal) async {
    final rows = _local.read().where((r) => r['id'] != goal.id).toList();
    await _local.write(rows);
    await _enqueue(
      SyncOpType.delete,
      table: 'goals',
      recordId: goal.id,
      data: const {},
    );
  }

  @override
  Future<void> addContribution({
    required String goalId,
    required Money amount,
    required DateTime occurredOn,
    String? note,
  }) async {
    final id = _uuid.v4();
    final cleanNote = (note?.trim().isEmpty ?? true) ? null : note!.trim();
    final contribution = {
      'id': id,
      'amount': amount.major,
      'occurred_on': _dateOnly(occurredOn),
      'note': cleanNote,
      'deleted_at': null,
    };

    final rows = _local.read().map((g) {
      if (g['id'] != goalId) return g;
      final list = [...(g['goal_contributions'] as List? ?? []), contribution];
      return {...g, 'goal_contributions': list};
    }).toList();
    await _local.write(rows);

    await _enqueue(
      SyncOpType.insert,
      table: 'goal_contributions',
      recordId: id,
      data: {
        'id': id,
        'goal_id': goalId,
        'user_id': _requireUser(),
        'amount': amount.major,
        'occurred_on': _dateOnly(occurredOn),
        'note': cleanNote,
      },
    );
  }

  @override
  Future<void> deleteContribution(String contributionId) async {
    final rows = _local.read().map((g) {
      final list = (g['goal_contributions'] as List? ?? [])
          .where((c) => (c as Map)['id'] != contributionId)
          .toList();
      return {...g, 'goal_contributions': list};
    }).toList();
    await _local.write(rows);

    await _enqueue(
      SyncOpType.delete,
      table: 'goal_contributions',
      recordId: contributionId,
      data: const {},
    );
  }

  // --- helpers -------------------------------------------------------------

  Future<void> _enqueue(
    SyncOpType type, {
    required String table,
    required String recordId,
    required Map<String, dynamic> data,
  }) async {
    await _queue.enqueue(
      PendingOp(
        id: _uuid.v4(),
        table: table,
        type: type,
        recordId: recordId,
        data: data,
        createdAt: DateTime.now(),
      ),
    );
    _onEnqueued?.call();
  }

  String _requireUser() {
    final id = _currentUserId();
    if (id == null) throw const AuthFailure('Not authenticated.');
    return id;
  }

  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
