import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:budgetiq/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:budgetiq/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

class _FakeRemote implements TransactionRemoteDataSource {
  _FakeRemote({
    this.rows = const [],
    this.olderRows = const [],
    this.throwOnFetch = false,
    this.hasOlder = false,
  });

  List<Map<String, dynamic>> rows;

  /// Rows returned when a bounded "load older" query is made.
  List<Map<String, dynamic>> olderRows;
  bool throwOnFetch;
  bool hasOlder;

  /// Records the arguments of the last [fetch] so tests can assert the query
  /// is actually bounded.
  DateTime? lastFrom;
  DateTime? lastTo;
  int? lastLimit;

  @override
  Future<List<Map<String, dynamic>>> fetch(
    TransactionKind kind, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    if (throwOnFetch) throw Exception('offline');
    lastFrom = from;
    lastTo = to;
    lastLimit = limit;
    return to == null ? rows : olderRows;
  }

  @override
  Future<bool> hasBefore(TransactionKind kind, DateTime date) async => hasOlder;
}

class _FakeLocal implements TransactionLocalDataSource {
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

TransactionRepositoryImpl _repo({
  required _FakeRemote remote,
  required _FakeLocal local,
  required FakeSyncQueue queue,
  required bool online,
}) {
  return TransactionRepositoryImpl(
    remote: remote,
    local: local,
    queue: queue,
    isOnline: () => online,
    currentUserId: () => 'user-1',
    resolveCategory: (kind, id) => id == null ? null : {'name': 'Salary'},
    currencyCode: 'USD',
  );
}

void main() {
  const kind = TransactionKind.income;

  test('online fetch maps rows and refreshes cache', () async {
    final remote = _FakeRemote(
      rows: [
        {
          'id': '1',
          'amount': 100.50,
          'currency_code': 'USD',
          'occurred_on': '2026-06-01',
          'category_id': 'c1',
          'income_categories': {'name': 'Salary'},
        },
      ],
    );
    final local = _FakeLocal();
    final repo = _repo(
      remote: remote,
      local: local,
      queue: FakeSyncQueue(),
      online: true,
    );

    final page = await repo.getTransactions(kind);
    expect(page.items.single.amount, Money.fromMajor(100.50));
    expect(page.items.single.categoryName, 'Salary');
    expect(local.store[kind], isNotEmpty);

    // The opening read is bounded rather than "everything ever recorded".
    expect(remote.lastFrom, isNotNull);
    expect(remote.lastLimit, kTransactionWindowMaxRows);
  });

  test('offline reads from cache', () async {
    final local = _FakeLocal()
      ..store[kind] = [
        {
          'id': '2',
          'amount': '42.00',
          'currency_code': 'USD',
          'occurred_on': '2026-06-02',
        },
      ];
    final repo = _repo(
      remote: _FakeRemote(throwOnFetch: true),
      local: local,
      queue: FakeSyncQueue(),
      online: false,
    );

    final page = await repo.getTransactions(kind);
    expect(page.items.single.amount, Money.fromMajor(42));
    expect(page.hasMore, isFalse, reason: 'cannot page while offline');
  });

  test(
    'offline create succeeds: updates cache and enqueues an insert op',
    () async {
      final local = _FakeLocal();
      final queue = FakeSyncQueue();
      final repo = _repo(
        remote: _FakeRemote(),
        local: local,
        queue: queue,
        online: false,
      );

      final created = await repo.createTransaction(
        kind: kind,
        amount: Money.fromMajor(25.75),
        occurredOn: DateTime(2026, 6, 13),
        categoryId: 'c1',
      );

      // Optimistically present in the cache for immediate display.
      expect(local.store[kind]!.single['id'], created.id);
      expect(created.categoryName, 'Salary');

      // Queued for sync with table-valid columns + user id.
      final op = queue.ops.single;
      expect(op.type, SyncOpType.insert);
      expect(op.table, 'income_transactions');
      expect(op.recordId, created.id);
      expect(op.data['amount'], 25.75);
      expect(op.data['user_id'], 'user-1');
      expect(op.data.containsKey('income_categories'), isFalse);
    },
  );

  test('update edits the cached row and enqueues an update op', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      online: false,
    );
    final created = await repo.createTransaction(
      kind: kind,
      amount: Money.fromMajor(10),
      occurredOn: DateTime(2026, 6, 1),
    );
    queue.ops.clear();

    final updated = await repo.updateTransaction(
      original: created,
      amount: Money.fromMajor(35),
      occurredOn: DateTime(2026, 6, 2),
    );

    expect(updated.amount, Money.fromMajor(35));
    expect(local.store[kind]!.single['amount'], 35.0);
    final op = queue.ops.single;
    expect(op.type, SyncOpType.update);
    expect(op.recordId, created.id);
    expect(op.data['amount'], 35.0);
  });

  test('delete removes the cached row and enqueues a delete op', () async {
    final local = _FakeLocal();
    final queue = FakeSyncQueue();
    final repo = _repo(
      remote: _FakeRemote(),
      local: local,
      queue: queue,
      online: false,
    );
    final created = await repo.createTransaction(
      kind: kind,
      amount: Money.fromMajor(10),
      occurredOn: DateTime(2026, 6, 1),
    );
    queue.ops.clear();

    await repo.deleteTransaction(created);

    expect(local.store[kind], isEmpty);
    expect(queue.ops.single.type, SyncOpType.delete);
    expect(queue.ops.single.recordId, created.id);
  });

  group('last-write-wins base', () {
    test(
      'an update carries the server version the edit was based on',
      () async {
        final local = _FakeLocal()
          ..store[kind] = [
            {
              'id': 'srv-1',
              'amount': 10.0,
              'currency_code': 'USD',
              'occurred_on': '2026-06-01',
              'updated_at': '2026-06-01T09:00:00.000Z',
            },
          ];
        final queue = FakeSyncQueue();
        final repo = _repo(
          remote: _FakeRemote(),
          local: local,
          queue: queue,
          online: false,
        );

        await repo.updateTransaction(
          original: Transaction(
            id: 'srv-1',
            kind: kind,
            amount: Money.fromMajor(10),
            occurredOn: DateTime(2026, 6, 1),
          ),
          amount: Money.fromMajor(12),
          occurredOn: DateTime(2026, 6, 1),
        );

        final op = queue.ops.single;
        expect(op.baseUpdatedAt, DateTime.parse('2026-06-01T09:00:00.000Z'));
        expect(
          op.data.containsKey('updated_at'),
          isFalse,
          reason: 'the server owns updated_at',
        );
        // Kept in the cache so a second offline edit still has a base.
        expect(
          local.store[kind]!.single['updated_at'],
          '2026-06-01T09:00:00.000Z',
        );
      },
    );

    test('a row created offline has no base, so the local edit wins', () async {
      final local = _FakeLocal();
      final queue = FakeSyncQueue();
      final repo = _repo(
        remote: _FakeRemote(),
        local: local,
        queue: queue,
        online: false,
      );
      final created = await repo.createTransaction(
        kind: kind,
        amount: Money.fromMajor(10),
        occurredOn: DateTime(2026, 6, 1),
      );
      queue.ops.clear();

      await repo.updateTransaction(
        original: created,
        amount: Money.fromMajor(11),
        occurredOn: DateTime(2026, 6, 1),
      );

      expect(queue.ops.single.baseUpdatedAt, isNull);
    });
  });

  group('paging older history', () {
    test(
      'load-older appends unseen rows to the cache and reports more',
      () async {
        final older = [
          for (var i = 0; i < kTransactionPageSize; i++)
            {
              'id': 'old-$i',
              'amount': 1.0,
              'currency_code': 'USD',
              'occurred_on': '2024-01-01',
            },
        ];
        final local = _FakeLocal()
          ..store[kind] = [
            {
              'id': 'recent',
              'amount': 5.0,
              'currency_code': 'USD',
              'occurred_on': '2026-06-01',
            },
          ];
        final remote = _FakeRemote(olderRows: older);
        final repo = _repo(
          remote: remote,
          local: local,
          queue: FakeSyncQueue(),
          online: true,
        );

        final page = await repo.getTransactions(
          kind,
          olderThan: DateTime(2026, 6, 1),
        );

        expect(remote.lastTo, DateTime(2026, 6, 1));
        expect(remote.lastLimit, kTransactionPageSize);
        expect(page.items, hasLength(kTransactionPageSize));
        expect(
          page.hasMore,
          isTrue,
          reason: 'a full page implies more history',
        );
        expect(local.store[kind], hasLength(kTransactionPageSize + 1));
      },
    );

    test('rows already loaded are not duplicated at a page boundary', () async {
      final shared = {
        'id': 'recent',
        'amount': 5.0,
        'currency_code': 'USD',
        'occurred_on': '2026-06-01',
      };
      final local = _FakeLocal()..store[kind] = [shared];
      final repo = _repo(
        // The inclusive bound returns the boundary row again.
        remote: _FakeRemote(olderRows: [shared]),
        local: local,
        queue: FakeSyncQueue(),
        online: true,
      );

      final page = await repo.getTransactions(
        kind,
        olderThan: DateTime(2026, 6, 1),
      );

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      expect(local.store[kind], hasLength(1));
    });

    test('the opening window reports whether older history exists', () async {
      final repo = _repo(
        remote: _FakeRemote(rows: const [], hasOlder: true),
        local: _FakeLocal(),
        queue: FakeSyncQueue(),
        online: true,
      );

      expect((await repo.getTransactions(kind)).hasMore, isTrue);
    });
  });
}
