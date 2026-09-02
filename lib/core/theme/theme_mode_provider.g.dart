// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controls the app [ThemeMode].
///
/// Defaults to [ThemeMode.system] and persists the user's explicit choice to
/// the Hive cache so it survives app restarts (and works offline). The cache
/// box is opened in `main()` before the app runs, so reads/writes are sync.

@ProviderFor(ThemeModeController)
final themeModeControllerProvider = ThemeModeControllerProvider._();

/// Controls the app [ThemeMode].
///
/// Defaults to [ThemeMode.system] and persists the user's explicit choice to
/// the Hive cache so it survives app restarts (and works offline). The cache
/// box is opened in `main()` before the app runs, so reads/writes are sync.
final class ThemeModeControllerProvider
    extends $NotifierProvider<ThemeModeController, ThemeMode> {
  /// Controls the app [ThemeMode].
  ///
  /// Defaults to [ThemeMode.system] and persists the user's explicit choice to
  /// the Hive cache so it survives app restarts (and works offline). The cache
  /// box is opened in `main()` before the app runs, so reads/writes are sync.
  ThemeModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeControllerHash();

  @$internal
  @override
  ThemeModeController create() => ThemeModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeControllerHash() =>
    r'4afe2fc39a9b04de01582472e1e9af43506032f1';

/// Controls the app [ThemeMode].
///
/// Defaults to [ThemeMode.system] and persists the user's explicit choice to
/// the Hive cache so it survives app restarts (and works offline). The cache
/// box is opened in `main()` before the app runs, so reads/writes are sync.

abstract class _$ThemeModeController extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
