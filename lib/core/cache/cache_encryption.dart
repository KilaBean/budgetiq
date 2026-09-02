import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Supplies the AES key that encrypts the Hive cache at rest.
///
/// The cache holds the user's full financial history offline, so it is
/// encrypted with a 256-bit key kept in the platform keystore (Android
/// KeyStore / iOS Keychain) rather than on disk beside the
/// data. The key is generated once per install and reused thereafter.
class CacheEncryption {
  const CacheEncryption(this._storage);

  /// Uses the Android KeyStore defaults (AES-GCM data encryption with an
  /// RSA-OAEP wrapped key) and a device-only Keychain entry on iOS that is
  /// readable after first unlock and never migrates to another device.
  factory CacheEncryption.platform() => const CacheEncryption(
    FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  );

  final FlutterSecureStorage _storage;

  static const String _keyName = 'cache_encryption_key';

  /// Returns the cipher for [kCacheBoxName], generating and storing a key on
  /// first run.
  Future<HiveAesCipher> cipher() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      final bytes = base64Url.decode(existing);
      if (bytes.length == 32) return HiveAesCipher(bytes);
    }
    final key = Hive.generateSecureKey();
    await _storage.write(key: _keyName, value: base64Url.encode(key));
    return HiveAesCipher(key);
  }
}
