// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_x.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's email, or `null` if unavailable.
///
/// Convenience selector derived from [authStateProvider] so widgets can read a
/// single value without unpacking the full [AsyncValue].

@ProviderFor(currentUserEmail)
final currentUserEmailProvider = CurrentUserEmailProvider._();

/// The signed-in user's email, or `null` if unavailable.
///
/// Convenience selector derived from [authStateProvider] so widgets can read a
/// single value without unpacking the full [AsyncValue].

final class CurrentUserEmailProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The signed-in user's email, or `null` if unavailable.
  ///
  /// Convenience selector derived from [authStateProvider] so widgets can read a
  /// single value without unpacking the full [AsyncValue].
  CurrentUserEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserEmailHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserEmailHash() => r'1cbf8d99fc4556d7895062bbf41c77b72220c835';
