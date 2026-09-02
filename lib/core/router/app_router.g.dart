// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The application router with auth-aware redirects.
///
/// Unauthenticated users are kept within the auth routes; authenticated users
/// are routed into the bottom-nav shell. Redirects re-run whenever the auth
/// session changes via [GoRouterRefreshStream].

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The application router with auth-aware redirects.
///
/// Unauthenticated users are kept within the auth routes; authenticated users
/// are routed into the bottom-nav shell. Redirects re-run whenever the auth
/// session changes via [GoRouterRefreshStream].

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The application router with auth-aware redirects.
  ///
  /// Unauthenticated users are kept within the auth routes; authenticated users
  /// are routed into the bottom-nav shell. Redirects re-run whenever the auth
  /// session changes via [GoRouterRefreshStream].
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'36a61000f5c798ea11f6ab0cb0247af6c3b4de8c';
