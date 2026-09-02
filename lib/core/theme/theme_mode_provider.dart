import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../cache/cache_box.dart';

part 'theme_mode_provider.g.dart';

/// Controls the app [ThemeMode].
///
/// Defaults to [ThemeMode.system] and persists the user's explicit choice to
/// the Hive cache so it survives app restarts (and works offline). The cache
/// box is opened in `main()` before the app runs, so reads/writes are sync.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final stored = ref.read(cacheBoxProvider).get(_key);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void set(ThemeMode mode) {
    state = mode;
    ref.read(cacheBoxProvider).put(_key, mode.name);
  }

  void toggle() {
    set(switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    });
  }
}
