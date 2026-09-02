import 'package:budgetiq/core/sync/pending_op.dart';
import 'package:budgetiq/core/sync/sync_queue.dart';

/// In-memory [SyncQueue] for unit tests — the real one needs an open Hive box.
///
/// Records dead letters so tests can assert that a permanently-rejected write
/// is retained rather than silently dropped.
class FakeSyncQueue implements SyncQueue {
  final List<PendingOp> ops = [];
  final List<DeadLetter> dead = [];

  @override
  List<PendingOp> all() => List.of(ops);

  @override
  bool get isNotEmpty => ops.isNotEmpty;

  @override
  int get length => ops.length;

  @override
  Future<void> enqueue(PendingOp op) async => ops.add(op);

  @override
  Future<void> remove(String opId) async =>
      ops.removeWhere((o) => o.id == opId);

  @override
  List<DeadLetter> deadLetters() => List.of(dead);

  @override
  int get deadLetterCount => dead.length;

  @override
  Future<void> recordDeadLetter(PendingOp op, String reason) async =>
      dead.add(DeadLetter(op: op, reason: reason, failedAt: DateTime(2026)));

  @override
  Future<void> clearDeadLetters() async => dead.clear();
}
