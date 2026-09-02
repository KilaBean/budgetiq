// ignore_for_file: prefer_initializing_formals — private DI fields cannot use
// initializing formals with named constructor params.
import 'pending_op.dart';
import 'remote_sync_api.dart';
import 'sync_queue.dart';

export 'remote_sync_api.dart' show TransientSyncException;

/// Outcome of a drain pass.
class SyncResult {
  const SyncResult({
    required this.synced,
    required this.remaining,
    this.failed = 0,
  });

  final int synced;
  final int remaining;

  /// Ops the server rejected permanently during this pass. They are dropped
  /// from the queue and reported via the engine's permanent-failure callback.
  final int failed;
}

/// Drains the [SyncQueue] to the backend, applying conflict resolution.
///
/// Policy (per Phase 0 design):
/// - **Inserts** are idempotent upserts by client-generated id, so replays are
///   safe.
/// - **Updates** use last-write-wins: if the server row changed since the local
///   edit's base, the server wins and the local op is dropped.
/// - **Deletes** are soft-deletes and idempotent.
///
/// A transient (network) failure stops the pass so it can be retried later
/// without losing ordering. A *permanent* failure (validation, permission)
/// cannot be retried into success, so the op is dropped to let the queue make
/// progress — but never silently: [onPermanentFailure] is invoked so it can be
/// logged, recorded and surfaced to the user.
class SyncEngine {
  SyncEngine({
    required SyncQueue queue,
    required RemoteSyncApi remote,
    Future<void> Function(PendingOp op, Object error, StackTrace stackTrace)?
    onPermanentFailure,
  }) : _queue = queue,
       _remote = remote,
       _onPermanentFailure = onPermanentFailure;

  final SyncQueue _queue;
  final RemoteSyncApi _remote;
  final Future<void> Function(PendingOp, Object, StackTrace)?
  _onPermanentFailure;

  bool _running = false;

  /// Processes queued ops in FIFO order. Safe to call repeatedly; concurrent
  /// calls are coalesced.
  Future<SyncResult> drain() async {
    if (_running) {
      return SyncResult(synced: 0, remaining: _queue.length);
    }
    _running = true;
    var synced = 0;
    var failed = 0;
    try {
      for (final op in _queue.all()) {
        final outcome = await _apply(op);
        if (outcome == _OpOutcome.transientFailure) break; // retry later
        await _queue.remove(op.id);
        if (outcome == _OpOutcome.permanentFailure) {
          failed++;
        } else {
          synced++;
        }
      }
    } finally {
      _running = false;
    }
    return SyncResult(synced: synced, remaining: _queue.length, failed: failed);
  }

  Future<_OpOutcome> _apply(PendingOp op) async {
    try {
      switch (op.type) {
        case SyncOpType.insert:
          await _remote.upsert(op.table, op.data);
        case SyncOpType.update:
          // Server wins under last-write-lose: drop the stale local edit.
          if (await _serverIsNewer(op)) return _OpOutcome.applied;
          await _remote.update(op.table, op.recordId, op.data);
        case SyncOpType.delete:
          await _remote.softDelete(op.table, op.recordId);
      }
      return _OpOutcome.applied;
    } on TransientSyncException {
      return _OpOutcome.transientFailure;
    } catch (error, stackTrace) {
      // Permanent failure (e.g. validation/permission): retrying can never
      // succeed, so drop the op to unblock the queue and report it.
      await _onPermanentFailure?.call(op, error, stackTrace);
      return _OpOutcome.permanentFailure;
    }
  }

  Future<bool> _serverIsNewer(PendingOp op) async {
    final base = op.baseUpdatedAt;
    if (base == null) return false;
    final serverUpdatedAt = await _remote.fetchUpdatedAt(op.table, op.recordId);
    if (serverUpdatedAt == null) return false;
    return serverUpdatedAt.isAfter(base);
  }
}

/// What happened to a single op during a drain pass.
enum _OpOutcome { applied, transientFailure, permanentFailure }
