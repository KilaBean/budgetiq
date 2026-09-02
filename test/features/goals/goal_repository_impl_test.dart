import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/features/goals/data/datasources/goal_local_data_source.dart';
import 'package:budgetiq/features/goals/data/datasources/goal_remote_data_source.dart';
import 'package:budgetiq/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

class _FakeRemote implements GoalRemoteDataSource {
  _FakeRemote({this.rows = const [], this.throwOnFetch = false});

  List<Map<String, dynamic>> rows;
  bool throwOnFetch;

  @override
  Future<List<Map<String, dynamic>>> fetchGoals() async {
    if (throwOnFetch) throw Exception('offline');
    return rows;
  }

  @override
  Future<Map<String, dynamic>> insertGoal(Map<String, dynamic> values) async =>
      values;

  @override
  Future<void> softDeleteGoal(String id) async {}

  @override
  Future<void> insertContribution(Map<String, dynamic> values) async {}

  @override
  Future<void> softDeleteContribution(String id) async {}
}

class _FakeLocal implements GoalLocalDataSource {
  List<Map<String, dynamic>> rows = [];

  @override
  List<Map<String, dynamic>> read() => rows;

  @override
  Future<void> write(List<Map<String, dynamic>> value) async => rows = value;
}

GoalRepositoryImpl _repo({
  required _FakeRemote remote,
  required _FakeLocal local,
  required FakeSyncQueue queue,
  bool online = false,
  String? userId = 'user-1',
}) => GoalRepositoryImpl(
  remote: remote,
  local: local,
  queue: queue,
  isOnline: () => online,
  currentUserId: () => userId,
  currencyCode: 'USD',
);

Map<String, dynamic> _goalRow({
  String id = 'g1',
  List<Map<String, dynamic>> contributions = const [],
}) => {
  'id': id,
  'name': 'Emergency fund',
  'target_amount': 1000.0,
  'currency_code': 'USD',
  'target_date': null,
  'status': 'active',
  'goal_contributions': contributions,
};

void main() {
  group('reads', () {
    test('online fetch maps rows and refreshes the cache', () async {
      final local = _FakeLocal();
      final repo = _repo(
        remote: _FakeRemote(
          rows: [
            _goalRow(
              contributions: [
                {
                  'id': 'c1',
                  'amount': 250.0,
                  'occurred_on': '2026-06-01',
                  'note': null,
                  'deleted_at': null,
                },
              ],
            ),
          ],
        ),
        local: local,
        queue: FakeSyncQueue(),
        online: true,
      );

      final goals = await repo.getGoals();

      expect(goals.single.name, 'Emergency fund');
      expect(goals.single.contributed, Money.fromMajor(250));
      expect(local.rows, hasLength(1));
    });

    test('offline reads from the cache', () async {
      final repo = _repo(
        remote: _FakeRemote(throwOnFetch: true),
        local: _FakeLocal()..rows = [_goalRow()],
        queue: FakeSyncQueue(),
      );

      expect((await repo.getGoals()).single.id, 'g1');
    });

    test(
      'a network failure with an empty cache surfaces a NetworkFailure',
      () async {
        final repo = _repo(
          remote: _FakeRemote(throwOnFetch: true),
          local: _FakeLocal(),
          queue: FakeSyncQueue(),
          online: true,
        );

        expect(repo.getGoals(), throwsA(isA<NetworkFailure>()));
      },
    );
  });

  group('writes', () {
    test('createGoal caches optimistically and queues an insert', () async {
      final local = _FakeLocal();
      final queue = FakeSyncQueue();
      final repo = _repo(remote: _FakeRemote(), local: local, queue: queue);

      final goal = await repo.createGoal(
        name: '  New car  ',
        targetAmount: Money.fromMajor(5000),
        targetDate: DateTime(2027, 1, 15),
      );

      expect(goal.name, 'New car', reason: 'name is trimmed');
      expect(local.rows.single['id'], goal.id);

      final op = queue.ops.single;
      expect(op.type, SyncOpType.insert);
      expect(op.table, 'goals');
      expect(op.recordId, goal.id);
      expect(op.data['user_id'], 'user-1');
      expect(op.data['target_date'], '2027-01-15');
    });

    test(
      'createGoal without a session fails before touching the queue',
      () async {
        final queue = FakeSyncQueue();
        final repo = _repo(
          remote: _FakeRemote(),
          local: _FakeLocal(),
          queue: queue,
          userId: null,
        );

        await expectLater(
          repo.createGoal(name: 'x', targetAmount: Money.fromMajor(10)),
          throwsA(isA<AuthFailure>()),
        );
        expect(queue.ops, isEmpty);
      },
    );

    test('deleteGoal drops it from the cache and queues a delete', () async {
      final local = _FakeLocal()..rows = [_goalRow(), _goalRow(id: 'g2')];
      final queue = FakeSyncQueue();
      final repo = _repo(remote: _FakeRemote(), local: local, queue: queue);

      await repo.deleteGoal(
        Goal(
          id: 'g1',
          name: 'Emergency fund',
          targetAmount: Money.fromMajor(1000),
          currencyCode: 'USD',
          contributions: const [],
        ),
      );

      expect(local.rows.single['id'], 'g2');
      expect(queue.ops.single.type, SyncOpType.delete);
      expect(queue.ops.single.recordId, 'g1');
    });

    test(
      'addContribution appends to the right goal and queues an insert',
      () async {
        final local = _FakeLocal()..rows = [_goalRow(), _goalRow(id: 'g2')];
        final queue = FakeSyncQueue();
        final repo = _repo(remote: _FakeRemote(), local: local, queue: queue);

        await repo.addContribution(
          goalId: 'g1',
          amount: Money.fromMajor(75.25),
          occurredOn: DateTime(2026, 6, 13),
          note: '   ',
        );

        final target = local.rows.firstWhere((g) => g['id'] == 'g1');
        final other = local.rows.firstWhere((g) => g['id'] == 'g2');
        expect((target['goal_contributions'] as List).single, isA<Map>());
        expect(other['goal_contributions'], isEmpty);

        final op = queue.ops.single;
        expect(op.table, 'goal_contributions');
        expect(op.data['goal_id'], 'g1');
        expect(op.data['amount'], 75.25);
        expect(op.data['occurred_on'], '2026-06-13');
        expect(
          op.data['note'],
          isNull,
          reason: 'blank notes are normalized away',
        );
      },
    );

    test('deleteContribution removes it from the cached goal', () async {
      final local = _FakeLocal()
        ..rows = [
          _goalRow(
            contributions: [
              {
                'id': 'c1',
                'amount': 10.0,
                'occurred_on': '2026-06-01',
                'deleted_at': null,
              },
              {
                'id': 'c2',
                'amount': 20.0,
                'occurred_on': '2026-06-02',
                'deleted_at': null,
              },
            ],
          ),
        ];
      final queue = FakeSyncQueue();
      final repo = _repo(remote: _FakeRemote(), local: local, queue: queue);

      await repo.deleteContribution('c1');

      final remaining = (local.rows.single['goal_contributions'] as List)
          .cast<Map>();
      expect(remaining.single['id'], 'c2');
      expect(queue.ops.single.recordId, 'c1');
    });
  });
}
