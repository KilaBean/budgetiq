// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(syncQueue)
final syncQueueProvider = SyncQueueProvider._();

final class SyncQueueProvider
    extends $FunctionalProvider<SyncQueue, SyncQueue, SyncQueue>
    with $Provider<SyncQueue> {
  SyncQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncQueueProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncQueueHash();

  @$internal
  @override
  $ProviderElement<SyncQueue> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncQueue create(Ref ref) {
    return syncQueue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncQueue>(value),
    );
  }
}

String _$syncQueueHash() => r'd63f1147e8308865de34ccce12dcc1afcfdfacc2';

@ProviderFor(syncEngine)
final syncEngineProvider = SyncEngineProvider._();

final class SyncEngineProvider
    extends $FunctionalProvider<SyncEngine, SyncEngine, SyncEngine>
    with $Provider<SyncEngine> {
  SyncEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncEngineHash();

  @$internal
  @override
  $ProviderElement<SyncEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncEngine create(Ref ref) {
    return syncEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncEngine>(value),
    );
  }
}

String _$syncEngineHash() => r'c3b01fe8859dcd22dc95a1d7f28fa416b858afc6';

/// Coordinates draining the offline queue: on startup, and whenever
/// connectivity is regained. After a successful drain it refreshes the
/// transaction lists so server-reconciled data replaces optimistic local rows.

@ProviderFor(SyncController)
final syncControllerProvider = SyncControllerProvider._();

/// Coordinates draining the offline queue: on startup, and whenever
/// connectivity is regained. After a successful drain it refreshes the
/// transaction lists so server-reconciled data replaces optimistic local rows.
final class SyncControllerProvider
    extends $NotifierProvider<SyncController, SyncStatus> {
  /// Coordinates draining the offline queue: on startup, and whenever
  /// connectivity is regained. After a successful drain it refreshes the
  /// transaction lists so server-reconciled data replaces optimistic local rows.
  SyncControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncControllerHash();

  @$internal
  @override
  SyncController create() => SyncController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncStatus>(value),
    );
  }
}

String _$syncControllerHash() => r'fd40337bcb70470009c2377a7540eebb2e71c690';

/// Coordinates draining the offline queue: on startup, and whenever
/// connectivity is regained. After a successful drain it refreshes the
/// transaction lists so server-reconciled data replaces optimistic local rows.

abstract class _$SyncController extends $Notifier<SyncStatus> {
  SyncStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SyncStatus, SyncStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncStatus, SyncStatus>,
              SyncStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
