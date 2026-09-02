// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localAuth)
final localAuthProvider = LocalAuthProvider._();

final class LocalAuthProvider
    extends
        $FunctionalProvider<
          LocalAuthentication,
          LocalAuthentication,
          LocalAuthentication
        >
    with $Provider<LocalAuthentication> {
  LocalAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAuthHash();

  @$internal
  @override
  $ProviderElement<LocalAuthentication> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalAuthentication create(Ref ref) {
    return localAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalAuthentication value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalAuthentication>(value),
    );
  }
}

String _$localAuthHash() => r'5628479258eabd9693eb6df68447df86aff385a3';

/// Whether the device can actually do biometric auth (enrolled fingerprint/etc).

@ProviderFor(biometricAvailable)
final biometricAvailableProvider = BiometricAvailableProvider._();

/// Whether the device can actually do biometric auth (enrolled fingerprint/etc).

final class BiometricAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the device can actually do biometric auth (enrolled fingerprint/etc).
  BiometricAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricAvailableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricAvailableHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return biometricAvailable(ref);
  }
}

String _$biometricAvailableHash() =>
    r'8240659a5c598dca8e4f91bb57ed068059de7d01';

/// User preference: require fingerprint to unlock the app. Persisted locally
/// (device-level), defaults off.

@ProviderFor(BiometricEnabled)
final biometricEnabledProvider = BiometricEnabledProvider._();

/// User preference: require fingerprint to unlock the app. Persisted locally
/// (device-level), defaults off.
final class BiometricEnabledProvider
    extends $NotifierProvider<BiometricEnabled, bool> {
  /// User preference: require fingerprint to unlock the app. Persisted locally
  /// (device-level), defaults off.
  BiometricEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricEnabledHash();

  @$internal
  @override
  BiometricEnabled create() => BiometricEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricEnabledHash() => r'8b96c6716f8524e86832d5fa5468ad2be5056e88';

/// User preference: require fingerprint to unlock the app. Persisted locally
/// (device-level), defaults off.

abstract class _$BiometricEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Prompts for biometric (fingerprint) authentication. Returns true on success.

@ProviderFor(BiometricGate)
final biometricGateProvider = BiometricGateProvider._();

/// Prompts for biometric (fingerprint) authentication. Returns true on success.
final class BiometricGateProvider
    extends $NotifierProvider<BiometricGate, bool> {
  /// Prompts for biometric (fingerprint) authentication. Returns true on success.
  BiometricGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricGateHash();

  @$internal
  @override
  BiometricGate create() => BiometricGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricGateHash() => r'7c37aaf56f284e7e572a33808d6791ecb3d46edd';

/// Prompts for biometric (fingerprint) authentication. Returns true on success.

abstract class _$BiometricGate extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
