import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown by a [RemoteSyncApi] when an operation fails for a *retryable*
/// reason (no connectivity, server unavailable). The engine halts and retries
/// later rather than dropping the op.
class TransientSyncException implements Exception {
  const TransientSyncException();
}

/// The remote operations the [SyncEngine] needs. Abstracted so the engine can
/// be unit-tested with a fake and kept independent of Supabase.
abstract interface class RemoteSyncApi {
  /// Current `updated_at` of a row, or `null` if it doesn't exist.
  Future<DateTime?> fetchUpdatedAt(String table, String recordId);

  /// Idempotent insert/update by primary key.
  Future<void> upsert(String table, Map<String, dynamic> data);

  Future<void> update(String table, String recordId, Map<String, dynamic> data);

  Future<void> softDelete(String table, String recordId);
}

/// Supabase-backed [RemoteSyncApi].
///
/// Network/server failures are reclassified as [TransientSyncException] so the
/// engine retries them; other errors (validation, permission) propagate and are
/// treated as permanent.
class SupabaseRemoteSyncApi implements RemoteSyncApi {
  SupabaseRemoteSyncApi(this._client);

  final SupabaseClient _client;

  @override
  Future<DateTime?> fetchUpdatedAt(String table, String recordId) {
    return _classify(() async {
      final row = await _client
          .from(table)
          .select('updated_at')
          .eq('id', recordId)
          .maybeSingle();
      final value = row?['updated_at'];
      return value == null ? null : DateTime.parse(value as String);
    });
  }

  @override
  Future<void> upsert(String table, Map<String, dynamic> data) {
    return _classify(() => _client.from(table).upsert(data));
  }

  @override
  Future<void> update(
    String table,
    String recordId,
    Map<String, dynamic> data,
  ) {
    return _classify(() => _client.from(table).update(data).eq('id', recordId));
  }

  @override
  Future<void> softDelete(String table, String recordId) {
    return _classify(
      () => _client
          .from(table)
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', recordId),
    );
  }

  Future<T> _classify<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      if (isTransientSyncError(e)) throw const TransientSyncException();
      rethrow;
    }
  }
}

/// Whether [error] is a *retryable* (network / server-unavailable) failure as
/// opposed to a permanent one (validation, permission, 4xx). Pure and testable.
bool isTransientSyncError(Object error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is PostgrestException) {
    // 5xx or missing status → server-side/connectivity issue, retry.
    final code = int.tryParse(error.code ?? '');
    return code == null || code >= 500;
  }
  return false;
}
