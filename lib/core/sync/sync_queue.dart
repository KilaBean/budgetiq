import '../cache/cache_box.dart';
import 'pending_op.dart';

/// Durable FIFO queue of [PendingOp]s, persisted in the Hive cache box so
/// queued writes survive app restarts.
///
/// Also holds the *dead-letter* list: ops the backend rejected permanently
/// (validation, permission). Those are kept rather than discarded so the user
/// can be told that a change never reached the server.
class SyncQueue {
  SyncQueue(this._cache);

  final JsonListCache _cache;

  /// Cache keys this queue owns. Public so a sign-out purge can preserve
  /// unsent work instead of destroying it.
  static const String queueKey = 'sync_queue';
  static const String deadLetterKey = 'sync_dead_letters';

  static const _key = queueKey;
  static const _deadLetterKey = deadLetterKey;

  /// Cap on retained dead letters — enough to explain what failed without
  /// growing without bound.
  static const int maxDeadLetters = 50;

  List<PendingOp> all() => _cache.read(_key).map(PendingOp.fromJson).toList();

  bool get isNotEmpty => _cache.read(_key).isNotEmpty;

  int get length => _cache.read(_key).length;

  Future<void> enqueue(PendingOp op) async {
    final ops = all()..add(op);
    await _persist(ops);
  }

  Future<void> remove(String opId) async {
    final ops = all()..removeWhere((o) => o.id == opId);
    await _persist(ops);
  }

  Future<void> _persist(List<PendingOp> ops) =>
      _cache.write(_key, ops.map((o) => o.toJson()).toList());

  // --- dead letters --------------------------------------------------------

  /// Ops the server permanently rejected, newest last.
  List<DeadLetter> deadLetters() =>
      _cache.read(_deadLetterKey).map(DeadLetter.fromJson).toList();

  int get deadLetterCount => _cache.read(_deadLetterKey).length;

  /// Records a permanently-failed [op] so it is visible rather than silently
  /// dropped. Oldest entries are trimmed past [maxDeadLetters].
  Future<void> recordDeadLetter(PendingOp op, String reason) async {
    final entries = _cache.read(_deadLetterKey)
      ..add(
        DeadLetter(op: op, reason: reason, failedAt: DateTime.now()).toJson(),
      );
    final trimmed = entries.length > maxDeadLetters
        ? entries.sublist(entries.length - maxDeadLetters)
        : entries;
    await _cache.write(_deadLetterKey, trimmed);
  }

  Future<void> clearDeadLetters() => _cache.write(_deadLetterKey, const []);
}

/// A queued write the backend rejected permanently, with why and when.
class DeadLetter {
  const DeadLetter({
    required this.op,
    required this.reason,
    required this.failedAt,
  });

  final PendingOp op;
  final String reason;
  final DateTime failedAt;

  Map<String, dynamic> toJson() => {
    ...op.toJson(),
    'failure_reason': reason,
    'failed_at': failedAt.toIso8601String(),
  };

  factory DeadLetter.fromJson(Map<String, dynamic> json) => DeadLetter(
    op: PendingOp.fromJson(json),
    reason: (json['failure_reason'] as String?) ?? 'Unknown error',
    failedAt: DateTime.parse(json['failed_at'] as String),
  );
}
