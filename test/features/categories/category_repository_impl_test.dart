import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/features/categories/data/datasources/category_local_data_source.dart';
import 'package:budgetiq/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:budgetiq/features/categories/data/repositories/category_repository_impl.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

class _FakeRemote implements CategoryRemoteDataSource {
  _FakeRemote({this.rows = const [], this.throwOnFetch = false});
  List<Map<String, dynamic>> rows;
  bool throwOnFetch;

  @override
  Future<List<Map<String, dynamic>>> fetch(TransactionKind kind) async {
    if (throwOnFetch) throw Exception('offline');
    return rows;
  }

  @override
  Future<Map<String, dynamic>> insert(
    TransactionKind kind,
    Map<String, dynamic> values,
  ) async => values;
  @override
  Future<Map<String, dynamic>> update(
    TransactionKind kind,
    String id,
    Map<String, dynamic> values,
  ) async => values;
  @override
  Future<void> softDelete(TransactionKind kind, String id) async {}
}

class _FakeLocal implements CategoryLocalDataSource {
  final Map<TransactionKind, List<Map<String, dynamic>>> store = {};
  @override
  List<Map<String, dynamic>> read(TransactionKind kind) =>
      store[kind] ?? const [];
  @override
  Future<void> write(
    TransactionKind kind,
    List<Map<String, dynamic>> rows,
  ) async {
    store[kind] = rows;
  }
}

CategoryRepositoryImpl _repo({
  required _FakeRemote remote,
  required _FakeLocal local,
  required FakeSyncQueue queue,
  required bool online,
}) => CategoryRepositoryImpl(
  remote: remote,
  local: local,
  queue: queue,
  isOnline: () => online,
  currentUserId: () => 'user-1',
);

void main() {
  const kind = TransactionKind.expense;

  test('online fetch maps rows and caches them', () async {
    final local = _FakeLocal();
    final repo = _repo(
      remote: _FakeRemote(
        rows: [
          {'id': '1', 'name': 'Food', 'is_system': true},
        ],
      ),
      local: local,
      queue: FakeSyncQueue(),
      online: true,
    );

    final result = await repo.getCategories(kind);
    expect(result.single.name, 'Food');
    expect(local.store[kind], isNotEmpty);
  });

  test('offline reads from cache', () async {
    final local = _FakeLocal()
      ..store[kind] = [
        {'id': '2', 'name': 'Transport', 'is_system': false},
      ];
    final repo = _repo(
      remote: _FakeRemote(throwOnFetch: true),
      local: local,
      queue: FakeSyncQueue(),
      online: false,
    );

    final result = await repo.getCategories(kind);
    expect(result.single.name, 'Transport');
  });

  test('offline create succeeds: caches and enqueues an insert op', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      online: false,
    );

    final created = await repo.createCategory(kind: kind, name: 'Gifts');

    expect(created.name, 'Gifts');
    expect(local.store[kind]!.single['name'], 'Gifts');
    final op = queue.ops.single;
    expect(op.type, SyncOpType.insert);
    expect(op.table, 'expense_categories');
    expect(op.data['user_id'], 'user-1');
    expect(op.data['is_system'], false);
  });

  test('update edits the cached row and enqueues an update op', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      online: false,
    );
    final created = await repo.createCategory(kind: kind, name: 'Food');
    queue.ops.clear();

    final edited = await repo.updateCategory(
      created.copyWith(name: 'Groceries'),
    );

    expect(edited.name, 'Groceries');
    expect(local.store[kind]!.single['name'], 'Groceries');
    final op = queue.ops.single;
    expect(op.type, SyncOpType.update);
    expect(op.recordId, created.id);
    expect(op.data['name'], 'Groceries');
  });

  test('online fetch error with cache falls back to cache', () async {
    final local = _FakeLocal()
      ..store[kind] = [
        {'id': '9', 'name': 'Cached', 'is_system': false},
      ];
    final repo = _repo(
      remote: _FakeRemote(throwOnFetch: true),
      local: local,
      queue: FakeSyncQueue(),
      online: true,
    );

    final result = await repo.getCategories(kind);
    expect(result.single.name, 'Cached');
  });

  test('delete removes from cache and enqueues a delete op', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      online: false,
    );
    final created = await repo.createCategory(kind: kind, name: 'Temp');
    queue.ops.clear();

    await repo.deleteCategory(created);

    expect(local.store[kind], isEmpty);
    expect(queue.ops.single.type, SyncOpType.delete);
    expect(queue.ops.single.recordId, created.id);
  });
}
