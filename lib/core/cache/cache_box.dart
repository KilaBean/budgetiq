import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/supabase_provider.dart';

part 'cache_box.g.dart';

/// Name of the single (encrypted) Hive box backing the offline read cache.
const String kCacheBoxName = 'budgetiq_cache_v2';

/// Name of the pre-encryption box, migrated from and deleted on first launch
/// of a build that ships encryption. See `cache_migration.dart`.
const String kLegacyCacheBoxName = 'budgetiq_cache';

/// Provides the opened Hive cache box.
///
/// The box is opened in `main()` before the app runs, so this returns the
/// already-open instance synchronously.
@Riverpod(keepAlive: true)
Box<dynamic> cacheBox(Ref ref) => Hive.box<dynamic>(kCacheBoxName);

/// Thin JSON-list cache over a Hive box, scoped to one user.
///
/// Stores lists of JSON-serializable maps under string keys. Used by data
/// sources to persist the last-known server state for offline reads.
///
/// Every key is namespaced with the owning user's id, so cached financial data
/// from a previous account is unreachable after a different user signs in on
/// the same device (a sign-out also purges it — see [CacheMaintenance]).
class JsonListCache {
  JsonListCache(this._box, {String? userId})
    : _prefix = userScopePrefix(userId);

  final Box<dynamic> _box;
  final String _prefix;

  /// Key prefix owning [userId]'s cached data. Signed-out reads/writes use a
  /// separate `anon` scope rather than silently sharing the last user's data.
  static String userScopePrefix(String? userId) =>
      userId == null ? 'u:anon:' : 'u:$userId:';

  String _scoped(String key) => '$_prefix$key';

  List<Map<String, dynamic>> read(String key) {
    final raw = _box.get(_scoped(key));
    if (raw is! String) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }

  Future<void> write(String key, List<Map<String, dynamic>> rows) =>
      _box.put(_scoped(key), jsonEncode(rows));
}

/// Deletes a user's cached data from the box — used on sign-out so financial
/// data does not outlive the session on a shared device.
class CacheMaintenance {
  CacheMaintenance(this._box);

  final Box<dynamic> _box;

  /// Removes every cache entry owned by [userId], except those named in
  /// [preserve] (unscoped key names).
  ///
  /// Device-level preferences (theme, biometric lock, notification settings)
  /// live under their own unscoped keys and are left alone either way.
  Future<void> clearUserScope(
    String? userId, {
    Set<String> preserve = const {},
  }) async {
    final prefix = JsonListCache.userScopePrefix(userId);
    final keys = _box.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .where((k) => !preserve.contains(k.substring(prefix.length)))
        .toList();
    if (keys.isEmpty) return;
    await _box.deleteAll(keys);
  }
}

@Riverpod(keepAlive: true)
CacheMaintenance cacheMaintenance(Ref ref) =>
    CacheMaintenance(ref.watch(cacheBoxProvider));

/// Cache scoped to the signed-in user. Rebuilds (and so re-scopes every
/// dependent repository) whenever the session changes.
@Riverpod(keepAlive: true)
JsonListCache jsonListCache(Ref ref) => JsonListCache(
  ref.watch(cacheBoxProvider),
  userId: ref.watch(currentUserIdProvider),
);
