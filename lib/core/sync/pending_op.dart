import 'package:equatable/equatable.dart';

/// The kind of mutation a [PendingOp] represents.
enum SyncOpType { insert, update, delete }

/// A queued write to be synced to Supabase when connectivity allows.
///
/// Ops are durable (persisted in Hive) and idempotent: inserts/updates target
/// a client-generated row [recordId], so replaying a synced op is a no-op
/// upsert. [baseUpdatedAt] enables last-write-wins conflict resolution on
/// updates.
class PendingOp extends Equatable {
  const PendingOp({
    required this.id,
    required this.table,
    required this.type,
    required this.recordId,
    required this.data,
    required this.createdAt,
    this.baseUpdatedAt,
  });

  /// Unique id of this queue entry.
  final String id;

  /// Target Postgres table.
  final String table;

  final SyncOpType type;

  /// Primary key of the affected row (client-generated for inserts).
  final String recordId;

  /// Column values to write (ignored for deletes).
  final Map<String, dynamic> data;

  final DateTime createdAt;

  /// `updated_at` the local change was based on, for LWW on updates.
  final DateTime? baseUpdatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'table': table,
    'type': type.name,
    'record_id': recordId,
    'data': data,
    'created_at': createdAt.toIso8601String(),
    'base_updated_at': baseUpdatedAt?.toIso8601String(),
  };

  factory PendingOp.fromJson(Map<String, dynamic> json) => PendingOp(
    id: json['id'] as String,
    table: json['table'] as String,
    type: SyncOpType.values.byName(json['type'] as String),
    recordId: json['record_id'] as String,
    data: (json['data'] as Map).cast<String, dynamic>(),
    createdAt: DateTime.parse(json['created_at'] as String),
    baseUpdatedAt: json['base_updated_at'] == null
        ? null
        : DateTime.parse(json['base_updated_at'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    table,
    type,
    recordId,
    data,
    createdAt,
    baseUpdatedAt,
  ];
}

/// The `updated_at` of a cached row, used as the base for last-write-wins
/// conflict resolution on an update op.
///
/// Returns `null` when the row has no server timestamp yet — a row created
/// offline, or one cached by a build that did not select the column. A null
/// base means "no known server version", so the local edit is applied
/// unconditionally, which matches the previous behaviour.
DateTime? baseUpdatedAtOf(Map<String, dynamic>? row) {
  final value = row?['updated_at'];
  if (value is! String) return null;
  return DateTime.tryParse(value);
}
