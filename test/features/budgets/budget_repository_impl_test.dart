import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/features/budgets/data/datasources/budget_local_data_source.dart';
import 'package:budgetiq/features/budgets/data/datasources/budget_remote_data_source.dart';
import 'package:budgetiq/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

/// Remote is never used by writes (outbox handles them); reads aren't exercised
/// here, so a minimal stub suffices.
class _FakeRemote implements BudgetRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> fetchBudget(String periodStart) async => null;
}

class _FakeLocal implements BudgetLocalDataSource {
  final Map<String, Map<String, dynamic>> store = {};
  @override
  Map<String, dynamic>? read(String periodStart) => store[periodStart];
  @override
  Future<void> write(String periodStart, Map<String, dynamic>? budget) async {
    if (budget == null) {
      store.remove(periodStart);
    } else {
      store[periodStart] = budget;
    }
  }
}

BudgetRepositoryImpl _repo(_FakeLocal local, FakeSyncQueue queue) =>
    BudgetRepositoryImpl(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      isOnline: () => false,
      currencyCode: 'USD',
      currentUserId: () => 'user-1',
      resolveCategoryName: (id) => 'Food',
    );

void main() {
  final month = Month.current();
  final period =
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}-01';

  test('offline setAllocation creates a local budget + insert ops', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(local, queue);

    final budget = await repo.setAllocation(
      month: month,
      expenseCategoryId: 'cat-food',
      amount: Money.fromMajor(400),
    );

    // Cached and returned with the allocation.
    expect(local.store[period], isNotNull);
    expect(budget.allocations.single.categoryName, 'Food');
    expect(budget.allocations.single.allocated, Money.fromMajor(400));

    // Enqueued a budget insert and a budget_categories insert.
    expect(queue.ops.where((o) => o.table == 'budgets').length, 1);
    final allocOp = queue.ops.firstWhere((o) => o.table == 'budget_categories');
    expect(allocOp.type, SyncOpType.insert);
    expect(allocOp.data['budget_id'], local.store[period]!['id']);
  });

  test('editing the same category reuses the allocation id (update)', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(local, queue);

    await repo.setAllocation(
      month: month,
      expenseCategoryId: 'cat-food',
      amount: Money.fromMajor(400),
    );
    final firstAllocId =
        (local.store[period]!['budget_categories'] as List).first['id']
            as String;
    queue.ops.clear();

    final budget = await repo.setAllocation(
      month: month,
      expenseCategoryId: 'cat-food',
      amount: Money.fromMajor(550),
    );

    // No duplicate allocation; same id; value updated.
    expect(budget.allocations.length, 1);
    expect(budget.allocations.single.allocated, Money.fromMajor(550));
    final op = queue.ops.single;
    expect(op.type, SyncOpType.update);
    expect(op.recordId, firstAllocId);
    // No new budget insert on the second call.
    expect(queue.ops.any((o) => o.table == 'budgets'), isFalse);
  });

  test('removeAllocation drops it from cache and enqueues a delete', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(local, queue);

    final budget = await repo.setAllocation(
      month: month,
      expenseCategoryId: 'cat-food',
      amount: Money.fromMajor(400),
    );
    queue.ops.clear();

    await repo.removeAllocation(budget.allocations.single);

    expect((local.store[period]!['budget_categories'] as List), isEmpty);
    final op = queue.ops.single;
    expect(op.type, SyncOpType.delete);
    expect(op.table, 'budget_categories');
    expect(op.recordId, budget.allocations.single.id);
  });

  test('offline getBudget reads from cache', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(local, queue);
    await repo.setAllocation(
      month: month,
      expenseCategoryId: 'cat-food',
      amount: Money.fromMajor(120),
    );

    final budget = await repo.getBudget(month);
    expect(budget, isNotNull);
    expect(budget!.allocations.single.allocated, Money.fromMajor(120));
  });
}
