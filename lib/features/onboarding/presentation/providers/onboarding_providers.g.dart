// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tracks whether the current user has completed first-run onboarding.
///
/// Stored locally (per user id) in the Hive cache — onboarding is a one-time UX
/// step, so it doesn't need to round-trip the backend.

@ProviderFor(OnboardingState)
final onboardingStateProvider = OnboardingStateProvider._();

/// Tracks whether the current user has completed first-run onboarding.
///
/// Stored locally (per user id) in the Hive cache — onboarding is a one-time UX
/// step, so it doesn't need to round-trip the backend.
final class OnboardingStateProvider
    extends $NotifierProvider<OnboardingState, bool> {
  /// Tracks whether the current user has completed first-run onboarding.
  ///
  /// Stored locally (per user id) in the Hive cache — onboarding is a one-time UX
  /// step, so it doesn't need to round-trip the backend.
  OnboardingStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStateHash();

  @$internal
  @override
  OnboardingState create() => OnboardingState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$onboardingStateHash() => r'455f45524eee0d239b339f675c6b8c4481259833';

/// Tracks whether the current user has completed first-run onboarding.
///
/// Stored locally (per user id) in the Hive cache — onboarding is a one-time UX
/// step, so it doesn't need to round-trip the backend.

abstract class _$OnboardingState extends $Notifier<bool> {
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
