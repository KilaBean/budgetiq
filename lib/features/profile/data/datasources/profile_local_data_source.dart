import '../../../../core/cache/cache_box.dart';

/// Hive-backed cache of the profile row for offline reads.
class ProfileLocalDataSource {
  ProfileLocalDataSource(this._cache);

  final JsonListCache _cache;

  static const _key = 'profile';

  Map<String, dynamic>? read() {
    final rows = _cache.read(_key);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> write(Map<String, dynamic>? profile) =>
      _cache.write(_key, profile == null ? [] : [profile]);
}
