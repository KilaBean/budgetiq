import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/core/sync/remote_sync_api.dart';
import 'package:budgetiq/core/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_sync_queue.dart';

class _FakeRemote implements RemoteSyncApi {
  final List<String> calls = [];
  DateTime? serverUpdatedAt;
  bool failTransiently = false;
  bool failPermanently = false;

  @override
  Future<DateTime?> fetchUpdatedAt(String table, String recordId) async =>
      serverUpdatedAt;

  @override
  Future<void> upsert(String table, Map<String, dynamic> data) async {
    if (failTransiently) throw const TransientSyncException();
    if (failPermanently) throw Exception('permanent');
    calls.add('upsert:${data['id']}');
  }

  @override
  Future<void> update(
    String table,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    if (failTransiently) throw const TransientSyncException();
    calls.add('update:$recordId');
  }

  @override
  Future<void> softDelete(String table, String recordId) async {
    calls.add('delete:$recordId');
  }
}

PendingOp _op(
  SyncOpType type, {
  String id = 'op',
  String recordId = 'r1',
  DateTime? base,
}) => PendingOp(
  id: id,
  table: 'income_transactions',
  type: type,
  recordId: recordId,
  data: {'id': recordId, 'amount': 10},
  createdAt: DateTime(2026, 6, 1),
  baseUpdatedAt: base,
);

void main() {
  test('drains queued ops in order and clears them', () async {
    final queue = FakeSyncQueue()
      ..ops.addAll([
        _op(SyncOpType.insert, id: 'o1', recordId: 'a'),
        _op(SyncOpType.delete, id: 'o2', recordId: 'b'),
      ]);
    final remote = _FakeRemote();
    final engine = SyncEngine(queue: queue, remote: remote);

    final result = await engine.drain();

    expect(result.synced, 2);
    expect(result.remaining, 0);
    expect(remote.calls, ['upsert:a', 'delete:b']);
  });

  test('transient failure halts the pass and keeps ops for retry', () async {
    final queue = FakeSyncQueue()..ops.add(_op(SyncOpType.insert));
    final remote = _FakeRemote()..failTransiently = true;
    final engine = SyncEngine(queue: queue, remote: remote);

    final result = await engine.drain();

    expect(result.synced, 0);
    expect(result.remaining, 1); // retained
  });

  test('permanent failure drops the op so the queue can progress', () async {
    final queue = FakeSyncQueue()..ops.add(_op(SyncOpType.insert));
    final remote = _FakeRemote()..failPermanently = true;
    final engine = SyncEngine(queue: queue, remote: remote);

    final result = await engine.drain();

    // Dropped so it cannot block the queue, but reported as failed rather
    // than counted as a successful sync.
    expect(result.remaining, 0);
    expect(result.failed, 1);
    expect(result.synced, 0);
  });

  test('LWW: newer server row skips the local update (server wins)', () async {
    final queue = FakeSyncQueue()
      ..ops.add(_op(SyncOpType.update, base: DateTime(2026, 6, 1)));
    final remote = _FakeRemote()..serverUpdatedAt = DateTime(2026, 6, 5);
    final engine = SyncEngine(queue: queue, remote: remote);

    final result = await engine.drain();

    expect(result.synced, 1); // op consumed
    expect(remote.calls, isEmpty); // but update not applied
  });

  test('LWW: unchanged server row applies the local update', () async {
    final queue = FakeSyncQueue()
      ..ops.add(
        _op(SyncOpType.update, recordId: 'r9', base: DateTime(2026, 6, 5)),
      );
    final remote = _FakeRemote()..serverUpdatedAt = DateTime(2026, 6, 1);
    final engine = SyncEngine(queue: queue, remote: remote);

    await engine.drain();

    expect(remote.calls, ['update:r9']);
  });
}
