import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed access to the current user's profile row.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not authenticated.');
    return id;
  }

  Future<Map<String, dynamic>?> fetch() async {
    return _client.from('profiles').select().eq('id', _userId).maybeSingle();
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> values) async {
    return _client
        .from('profiles')
        .update(values)
        .eq('id', _userId)
        .select()
        .single();
  }
}
