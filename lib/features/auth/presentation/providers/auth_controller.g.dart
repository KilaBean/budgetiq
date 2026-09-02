// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives auth mutations (sign in / up / out / reset) and exposes their
/// progress as an [AsyncValue].
///
/// The UI watches this controller for loading/error feedback, while reactive
/// session state (who is logged in) comes from [authStateProvider]. Errors are
/// normalized to a user-facing message via [Failure].

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Drives auth mutations (sign in / up / out / reset) and exposes their
/// progress as an [AsyncValue].
///
/// The UI watches this controller for loading/error feedback, while reactive
/// session state (who is logged in) comes from [authStateProvider]. Errors are
/// normalized to a user-facing message via [Failure].
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Drives auth mutations (sign in / up / out / reset) and exposes their
  /// progress as an [AsyncValue].
  ///
  /// The UI watches this controller for loading/error feedback, while reactive
  /// session state (who is logged in) comes from [authStateProvider]. Errors are
  /// normalized to a user-facing message via [Failure].
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'28872b290fdb928eb6b46c0aa7b60025a6e41c6a';

/// Drives auth mutations (sign in / up / out / reset) and exposes their
/// progress as an [AsyncValue].
///
/// The UI watches this controller for loading/error feedback, while reactive
/// session state (who is logged in) comes from [authStateProvider]. Errors are
/// normalized to a user-facing message via [Failure].

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
