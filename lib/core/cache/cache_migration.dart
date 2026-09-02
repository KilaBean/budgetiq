import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../observability/app_logger.dart';
import 'cache_box.dart';

/// Keys that belong to the device rather than to an account, and so migrate
/// across as-is. Everything else in the legacy box is per-user data that must
/// be re-scoped (see [migrateLegacyCache]).
bool _isDevicePreference(String key) =>
    key == 'theme_mode' ||
    key == 'biometric_enabled' ||
    key.startsWith('notif_') ||
    key.startsWith('onboarding_done');

/// Copies the contents of the pre-encryption box into the encrypted one, then
/// deletes the old box from disk.
///
/// The legacy box was written before cache keys were namespaced per user, so
/// its data entries are re-scoped to the account that owned them. That owner is
/// read from the cached `profile` row — the legacy box could only ever hold one
/// signed-in user's data. If no profile was cached there is no safe owner to
/// attribute the data to, so it is dropped rather than risk showing it to the
/// next person who signs in; it is a cache, and refetches on next load.
Future<void> migrateLegacyCache(Box<dynamic> target) async {
  if (!await Hive.boxExists(kLegacyCacheBoxName)) return;

  Box<dynamic> legacy;
  try {
    legacy = await Hive.openBox<dynamic>(kLegacyCacheBoxName);
  } catch (e, st) {
    // Unreadable legacy box: nothing to preserve, and leaving it on disk would
    // retry this every launch.
    AppLogger.error(e, stackTrace: st, context: 'cache-migration');
    await Hive.deleteBoxFromDisk(kLegacyCacheBoxName);
    return;
  }

  final ownerId = _cachedProfileId(legacy);
  final prefix = JsonListCache.userScopePrefix(ownerId);

  for (final key in legacy.keys.whereType<String>()) {
    final value = legacy.get(key);
    if (value == null) continue;
    if (_isDevicePreference(key)) {
      await target.put(key, value);
    } else if (ownerId != null) {
      await target.put('$prefix$key', value);
    }
  }

  await legacy.close();
  await Hive.deleteBoxFromDisk(kLegacyCacheBoxName);
}

/// The user id from the legacy box's cached profile row, if present.
String? _cachedProfileId(Box<dynamic> legacy) {
  final raw = legacy.get('profile');
  if (raw is! String) return null;
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List || decoded.isEmpty) return null;
    final first = decoded.first;
    if (first is! Map) return null;
    final id = first['id'];
    return id is String && id.isNotEmpty ? id : null;
  } catch (_) {
    return null;
  }
}
