import '../../../../core/cache/cache_box.dart';

/// Hive-backed cache of goal rows (with embedded contributions) for offline
/// reads.
class GoalLocalDataSource {
  GoalLocalDataSource(this._cache);

  final JsonListCache _cache;

  static const _key = 'goals';

  List<Map<String, dynamic>> read() => _cache.read(_key);

  Future<void> write(List<Map<String, dynamic>> rows) =>
      _cache.write(_key, rows);
}
