import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/auth/presentation/widgets/biometric_gate.dart';

/// Root application widget.
///
/// Wires the auth-aware router and light/dark Material 3 themes. The active
/// [ThemeMode] is driven by [themeModeControllerProvider].
class BudgetIqApp extends ConsumerWidget {
  const BudgetIqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'BudgetIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          BiometricGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
