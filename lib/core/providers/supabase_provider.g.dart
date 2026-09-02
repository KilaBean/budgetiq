// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the initialized [SupabaseClient].
///
/// [Supabase.initialize] must have completed in `main()` before this provider
/// is read. The data layer depends on this provider rather than referencing
/// the global singleton directly, keeping it injectable for tests.

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Exposes the initialized [SupabaseClient].
///
/// [Supabase.initialize] must have completed in `main()` before this provider
/// is read. The data layer depends on this provider rather than referencing
/// the global singleton directly, keeping it injectable for tests.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Exposes the initialized [SupabaseClient].
  ///
  /// [Supabase.initialize] must have completed in `main()` before this provider
  /// is read. The data layer depends on this provider rather than referencing
  /// the global singleton directly, keeping it injectable for tests.
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';

/// Id of the signed-in user, or `null` when signed out.
///
/// Seeded synchronously from the restored session (Supabase populates
/// `currentUser` before emitting the auth event) and kept current from the auth
/// stream, so cache scoping switches the moment the session does.

@ProviderFor(CurrentUserId)
final currentUserIdProvider = CurrentUserIdProvider._();

/// Id of the signed-in user, or `null` when signed out.
///
/// Seeded synchronously from the restored session (Supabase populates
/// `currentUser` before emitting the auth event) and kept current from the auth
/// stream, so cache scoping switches the moment the session does.
final class CurrentUserIdProvider
    extends $NotifierProvider<CurrentUserId, String?> {
  /// Id of the signed-in user, or `null` when signed out.
  ///
  /// Seeded synchronously from the restored session (Supabase populates
  /// `currentUser` before emitting the auth event) and kept current from the auth
  /// stream, so cache scoping switches the moment the session does.
  CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  CurrentUserId create() => CurrentUserId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'6bc294a7f86916844659a0e9881e5288ebe996f8';

/// Id of the signed-in user, or `null` when signed out.
///
/// Seeded synchronously from the restored session (Supabase populates
/// `currentUser` before emitting the auth event) and kept current from the auth
/// stream, so cache scoping switches the moment the session does.

abstract class _$CurrentUserId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
