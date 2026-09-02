import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/core/sync/remote_sync_api.dart';
import 'package:budgetiq/core/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

/// Remote that rejects every write the way Postgres rejects an invalid row.
class _RejectingRemote implements RemoteSyncApi {
  @override
  Future<DateTime?> fetchUpdatedAt(String table, String recordId) async => null;

  @override
  Future<void> upsert(String table, Map<String, dynamic> data) async {
    throw Exception('violates check constraint');
  }

  @override
  Future<void> update(
    String table,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    throw Exception('violates check constraint');
  }

  @override
  Future<void> softDelete(String table, String recordId) async {
    throw Exception('violates check constraint');
  }
}

PendingOp _op(String id) => PendingOp(
  id: id,
  table: 'income_transactions',
  type: SyncOpType.insert,
  recordId: 'r-$id',
  data: const {'amount': -5},
  createdAt: DateTime(2026, 6, 1),
);

void main() {
  group('permanently rejected ops', () {
    test(
      'are reported, recorded and counted rather than silently dropped',
      () async {
        final queue = FakeSyncQueue();
        await queue.enqueue(_op('1'));
        final reported = <PendingOp>[];

        final engine = SyncEngine(
          queue: queue,
          remote: _RejectingRemote(),
          onPermanentFailure: (op, error, stackTrace) async {
            reported.add(op);
            await queue.recordDeadLetter(op, error.toString());
          },
        );

        final result = await engine.drain();

        expect(reported.single.id, '1');
        expect(result.failed, 1);
        expect(result.synced, 0);
        // Dropped from the queue so it cannot block later writes forever...
        expect(result.remaining, 0);
        // ...but still visible to the user.
        expect(queue.deadLetterCount, 1);
        expect(queue.deadLetters().single.reason, contains('check constraint'));
      },
    );

    test('do not stop the pass: later ops still sync', () async {
      final queue = FakeSyncQueue();
      await queue.enqueue(_op('1'));
      await queue.enqueue(_op('2'));

      final engine = SyncEngine(
        queue: queue,
        remote: _RejectingRemote(),
        onPermanentFailure: (op, error, stackTrace) async =>
            queue.recordDeadLetter(op, error.toString()),
      );

      final result = await engine.drain();

      expect(result.failed, 2);
      expect(result.remaining, 0);
    });

    test('an engine without a callback still drops and counts them', () async {
      final queue = FakeSyncQueue();
      await queue.enqueue(_op('1'));

      final result = await SyncEngine(
        queue: queue,
        remote: _RejectingRemote(),
      ).drain();

      expect(result.failed, 1);
      expect(queue.deadLetterCount, 0);
    });
  });
}
