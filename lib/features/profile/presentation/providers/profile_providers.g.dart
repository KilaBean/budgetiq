// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'dd724cc61bd1b7f0ddf70d3940bcade43ef31068';

/// The current user's profile.

@ProviderFor(CurrentProfile)
final currentProfileProvider = CurrentProfileProvider._();

/// The current user's profile.
final class CurrentProfileProvider
    extends $AsyncNotifierProvider<CurrentProfile, Profile> {
  /// The current user's profile.
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  CurrentProfile create() => CurrentProfile();
}

String _$currentProfileHash() => r'6b44e1ad586ab2b02fc5d7bd402e9188a69374a5';

/// The current user's profile.

abstract class _$CurrentProfile extends $AsyncNotifier<Profile> {
  FutureOr<Profile> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile>, Profile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile>, Profile>,
              AsyncValue<Profile>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The active currency code for money entry/formatting. Defaults to USD until
/// the profile resolves, so forms always have a sensible value.

@ProviderFor(currencyCode)
final currencyCodeProvider = CurrencyCodeProvider._();

/// The active currency code for money entry/formatting. Defaults to USD until
/// the profile resolves, so forms always have a sensible value.

final class CurrencyCodeProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The active currency code for money entry/formatting. Defaults to USD until
  /// the profile resolves, so forms always have a sensible value.
  CurrencyCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyCodeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyCodeHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currencyCode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currencyCodeHash() => r'ae742cfbe113a76701cc785f96c5af2c2cd7f203';
