import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';

part 'biometric_providers.g.dart';

@Riverpod(keepAlive: true)
LocalAuthentication localAuth(Ref ref) => LocalAuthentication();

/// Whether the device can actually do biometric auth (enrolled fingerprint/etc).
@riverpod
Future<bool> biometricAvailable(Ref ref) async {
  final auth = ref.watch(localAuthProvider);
  try {
    final supported = await auth.isDeviceSupported();
    final canCheck = await auth.canCheckBiometrics;
    return supported && canCheck;
  } catch (_) {
    return false;
  }
}

/// User preference: require fingerprint to unlock the app. Persisted locally
/// (device-level), defaults off.
@Riverpod(keepAlive: true)
class BiometricEnabled extends _$BiometricEnabled {
  static const _key = 'biometric_enabled';

  @override
  bool build() => ref.read(cacheBoxProvider).get(_key) == true;

  Future<void> set(bool value) async {
    await ref.read(cacheBoxProvider).put(_key, value);
    state = value;
  }
}

/// Prompts for biometric (fingerprint) authentication. Returns true on success.
@Riverpod(keepAlive: true)
class BiometricGate extends _$BiometricGate {
  @override
  bool build() => false; // true once unlocked this session

  Future<bool> authenticate() async {
    try {
      final ok = await ref
          .read(localAuthProvider)
          .authenticate(
            localizedReason: 'Unlock BudgetIQ',
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          );
      if (ok) state = true;
      return ok;
    } catch (_) {
      return false;
    }
  }

  void reset() => state = false;
}
