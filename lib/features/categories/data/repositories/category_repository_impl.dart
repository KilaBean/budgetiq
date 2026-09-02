// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/sync/pending_op.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';

/// Offline-first [CategoryRepository].
///
/// Reads prefer the network (refreshing the Hive cache) and fall back to cache
/// offline. Writes apply to the cache optimistically and enqueue an outbox op,
/// so creating/editing/deleting categories works offline and syncs later.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryRemoteDataSource remote,
    required CategoryLocalDataSource local,
    required SyncQueue queue,
    required bool Function() isOnline,
    required String? Function() currentUserId,
    void Function()? onEnqueued,
  }) : _remote = remote,
       _local = local,
       _queue = queue,
       _isOnline = isOnline,
       _currentUserId = currentUserId,
       _onEnqueued = onEnqueued;

  final CategoryRemoteDataSource _remote;
  final CategoryLocalDataSource _local;
  final SyncQueue _queue;
  final bool Function() _isOnline;
  final String? Function() _currentUserId;
  final void Function()? _onEnqueued;

  static const _uuid = Uuid();

  @override
  Future<List<Category>> getCategories(TransactionKind kind) async {
    if (!_isOnline()) {
      return _mapRows(_local.read(kind), kind);
    }
    try {
      final rows = await _remote.fetch(kind);
      await _local.write(kind, rows);
      return _mapRows(rows, kind);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      final cached = _local.read(kind);
      if (cached.isNotEmpty) return _mapRows(cached, kind);
      throw const NetworkFailure('Could not load categories.');
    }
  }

  @override
  Future<Category> createCategory({
    required TransactionKind kind,
    required String name,
    String? icon,
    String? color,
  }) async {
    final id = _uuid.v4();
    final row = {
      'id': id,
      'name': name.trim(),
      'icon': icon,
      'color': color,
      'is_system': false,
    };
    await _local.write(kind, [..._local.read(kind), row]);
    await _enqueue(
      SyncOpType.insert,
      table: kind.categoryTable,
      recordId: id,
      data: {'user_id': _requireUser(), ...row},
    );
    return CategoryModel.fromJson(row, kind);
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final rows = _local.read(category.kind);
    final index = rows.indexWhere((r) => r['id'] == category.id);
    final existing = index >= 0 ? rows[index] : null;

    final row = {
      'id': category.id,
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'is_system': category.isSystem,
      // Kept so a later edit knows which server version it is based on.
      if (existing?['updated_at'] != null)
        'updated_at': existing!['updated_at'],
    };
    await _local.write(
      category.kind,
      rows.map((r) => r['id'] == category.id ? row : r).toList(),
    );
    await _enqueue(
      SyncOpType.update,
      table: category.kind.categoryTable,
      recordId: category.id,
      data: {
        'name': category.name,
        'icon': category.icon,
        'color': category.color,
      },
      baseUpdatedAt: baseUpdatedAtOf(existing),
    );
    return category;
  }

  @override
  Future<void> deleteCategory(Category category) async {
    final rows = _local
        .read(category.kind)
        .where((r) => r['id'] != category.id)
        .toList();
    await _local.write(category.kind, rows);
    await _enqueue(
      SyncOpType.delete,
      table: category.kind.categoryTable,
      recordId: category.id,
      data: const {},
    );
  }

  // --- helpers -------------------------------------------------------------

  List<Category> _mapRows(
    List<Map<String, dynamic>> rows,
    TransactionKind kind,
  ) => rows.map((r) => CategoryModel.fromJson(r, kind)).toList();

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
