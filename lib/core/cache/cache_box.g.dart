// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_box.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the opened Hive cache box.
///
/// The box is opened in `main()` before the app runs, so this returns the
/// already-open instance synchronously.

@ProviderFor(cacheBox)
final cacheBoxProvider = CacheBoxProvider._();

/// Provides the opened Hive cache box.
///
/// The box is opened in `main()` before the app runs, so this returns the
/// already-open instance synchronously.

final class CacheBoxProvider
    extends $FunctionalProvider<Box<dynamic>, Box<dynamic>, Box<dynamic>>
    with $Provider<Box<dynamic>> {
  /// Provides the opened Hive cache box.
  ///
  /// The box is opened in `main()` before the app runs, so this returns the
  /// already-open instance synchronously.
  CacheBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheBoxHash();

  @$internal
  @override
  $ProviderElement<Box<dynamic>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Box<dynamic> create(Ref ref) {
    return cacheBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<dynamic>>(value),
    );
  }
}

String _$cacheBoxHash() => r'51facbcb21cd094878acc2c52af102c4999b57bc';

@ProviderFor(cacheMaintenance)
final cacheMaintenanceProvider = CacheMaintenanceProvider._();

final class CacheMaintenanceProvider
    extends
        $FunctionalProvider<
          CacheMaintenance,
          CacheMaintenance,
          CacheMaintenance
        >
    with $Provider<CacheMaintenance> {
  CacheMaintenanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheMaintenanceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheMaintenanceHash();

  @$internal
  @override
  $ProviderElement<CacheMaintenance> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheMaintenance create(Ref ref) {
    return cacheMaintenance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheMaintenance value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheMaintenance>(value),
    );
  }
}

String _$cacheMaintenanceHash() => r'76c481ed10bbf5e6a681d5a9ae1c7bf7a7c60fe9';

/// Cache scoped to the signed-in user. Rebuilds (and so re-scopes every
/// dependent repository) whenever the session changes.

@ProviderFor(jsonListCache)
final jsonListCacheProvider = JsonListCacheProvider._();

/// Cache scoped to the signed-in user. Rebuilds (and so re-scopes every
/// dependent repository) whenever the session changes.

final class JsonListCacheProvider
    extends $FunctionalProvider<JsonListCache, JsonListCache, JsonListCache>
    with $Provider<JsonListCache> {
  /// Cache scoped to the signed-in user. Rebuilds (and so re-scopes every
  /// dependent repository) whenever the session changes.
  JsonListCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jsonListCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jsonListCacheHash();

  @$internal
  @override
  $ProviderElement<JsonListCache> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JsonListCache create(Ref ref) {
    return jsonListCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JsonListCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JsonListCache>(value),
    );
  }
}

String _$jsonListCacheHash() => r'f646658c5f67d73a300157e65447ea3e1cd9b252';
