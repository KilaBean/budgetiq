// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'63bb346f5fb591f4a743ff0f8e30cfe31cbb1083';

@ProviderFor(NotificationSettingsController)
final notificationSettingsControllerProvider =
    NotificationSettingsControllerProvider._();

final class NotificationSettingsControllerProvider
    extends
        $NotifierProvider<
          NotificationSettingsController,
          NotificationSettings
        > {
  NotificationSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsControllerHash();

  @$internal
  @override
  NotificationSettingsController create() => NotificationSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationSettings>(value),
    );
  }
}

String _$notificationSettingsControllerHash() =>
    r'cb478aa69dc47490326d7f0f5baf3d64832a2a05';

abstract class _$NotificationSettingsController
    extends $Notifier<NotificationSettings> {
  NotificationSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationSettings, NotificationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationSettings, NotificationSettings>,
              NotificationSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Durable log of already-fired alert keys so each alert notifies once.

@ProviderFor(NotificationLog)
final notificationLogProvider = NotificationLogProvider._();

/// Durable log of already-fired alert keys so each alert notifies once.
final class NotificationLogProvider
    extends $NotifierProvider<NotificationLog, Set<String>> {
  /// Durable log of already-fired alert keys so each alert notifies once.
  NotificationLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLogHash();

  @$internal
  @override
  NotificationLog create() => NotificationLog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$notificationLogHash() => r'c4c408e1b6cee194cff185211e4142edf16c211d';

/// Durable log of already-fired alert keys so each alert notifies once.

abstract class _$NotificationLog extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
