import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed access to goals and contributions.
class GoalRemoteDataSource {
  GoalRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _goalSelect =
      'id, name, target_amount, target_date, currency_code, status, '
      'goal_contributions(id, amount, occurred_on, note, deleted_at)';

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Not authenticated.');
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchGoals() async {
    return _client
        .from('goals')
        .select(_goalSelect)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> insertGoal(Map<String, dynamic> values) {
    return _client
        .from('goals')
        .insert({...values, 'user_id': _userId})
        .select(_goalSelect)
        .single();
  }

  Future<void> softDeleteGoal(String id) async {
    await _client
        .from('goals')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> insertContribution(Map<String, dynamic> values) async {
    await _client.from('goal_contributions').insert({
      ...values,
      'user_id': _userId,
    });
  }

  Future<void> softDeleteContribution(String id) async {
    await _client
        .from('goal_contributions')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
