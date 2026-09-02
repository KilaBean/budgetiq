import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/domain/transaction_kind.dart';

/// Supabase-backed CRUD for category tables.
///
/// Returns raw JSON rows; mapping to entities and [Failure] translation happen
/// in the repository.
class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const AuthException('Not authenticated.');
    }
    return id;
  }

  Future<List<Map<String, dynamic>>> fetch(TransactionKind kind) async {
    final rows = await _client
        .from(kind.categoryTable)
        .select()
        .isFilter('deleted_at', null)
        .order('name');
    return rows;
  }

  Future<Map<String, dynamic>> insert(
    TransactionKind kind,
    Map<String, dynamic> values,
  ) async {
    return _client
        .from(kind.categoryTable)
        .insert({...values, 'user_id': _userId})
        .select()
        .single();
  }

  Future<Map<String, dynamic>> update(
    TransactionKind kind,
    String id,
    Map<String, dynamic> values,
  ) async {
    return _client
        .from(kind.categoryTable)
        .update(values)
        .eq('id', id)
        .select()
        .single();
  }

  Future<void> softDelete(TransactionKind kind, String id) async {
    await _client
        .from(kind.categoryTable)
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
