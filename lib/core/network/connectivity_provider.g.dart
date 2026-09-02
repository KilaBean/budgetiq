// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits `true` when the device has a network connection, `false` otherwise.
///
/// Used by repositories to decide between network and cached data, and by the
/// sync layer to know when it can reach Supabase.

@ProviderFor(connectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

/// Emits `true` when the device has a network connection, `false` otherwise.
///
/// Used by repositories to decide between network and cached data, and by the
/// sync layer to know when it can reach Supabase.

final class ConnectivityStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Emits `true` when the device has a network connection, `false` otherwise.
  ///
  /// Used by repositories to decide between network and cached data, and by the
  /// sync layer to know when it can reach Supabase.
  ConnectivityStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return connectivityStatus(ref);
  }
}

String _$connectivityStatusHash() =>
    r'2c63d64d82af167c2b8e20ddd1933956892ee2fd';

/// Synchronous best-effort online flag (defaults to online until the stream
/// resolves) for use inside repositories.

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Synchronous best-effort online flag (defaults to online until the stream
/// resolves) for use inside repositories.

final class IsOnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Synchronous best-effort online flag (defaults to online until the stream
  /// resolves) for use inside repositories.
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnlineHash() => r'9d4eda2c5e0c231a01f08a0feb9aa7812d4e4c64';
