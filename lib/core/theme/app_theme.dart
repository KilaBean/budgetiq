
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized Material 3 theming for BudgetIQ (light + dark).
///
/// Both themes are derived from a single seed color for consistency and
/// expose [FinancialColors] for income/expense semantics. Typography and
/// component shapes target a clean, fintech-grade look.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light, FinancialColors.light);

  static ThemeData dark() => _build(Brightness.dark, FinancialColors.dark);

  static ThemeData _build(Brightness brightness, FinancialColors financial) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [financial],
      // Smooth, modern page transitions across platforms.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        // Dark surfaces sit close together, so cards need a higher tier than
        // in light or they visually merge into the scaffold.
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 68,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Inter throughout, with **tabular figures** everywhere.
  ///
  /// Proportional digits make money jump around: columns of amounts fail to
  /// line up, and a counting [AnimatedAmount] visibly reflows on every frame.
  /// Fixed-width digits are the norm in finance UIs for exactly that reason.
  ///
  /// Display and headline sizes also get slightly tighter tracking, which Inter
  /// needs at large optical sizes.
  static TextTheme _textTheme(TextTheme base) {
    TextStyle? body(TextStyle? style) => style?.copyWith(
      fontFamily: 'Inter',
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    TextStyle? tight(TextStyle? style) =>
        body(style)?.copyWith(letterSpacing: -0.5);

    return TextTheme(
      displayLarge: tight(base.displayLarge),
      displayMedium: tight(base.displayMedium),
      displaySmall: tight(base.displaySmall),
      headlineLarge: tight(base.headlineLarge),
      headlineMedium: tight(base.headlineMedium),
      headlineSmall: tight(base.headlineSmall),
      titleLarge: body(base.titleLarge),
      titleMedium: body(base.titleMedium),
      titleSmall: body(base.titleSmall),
      bodyLarge: body(base.bodyLarge),
      bodyMedium: body(base.bodyMedium),
      bodySmall: body(base.bodySmall),
      labelLarge: body(base.labelLarge),
      labelMedium: body(base.labelMedium),
      labelSmall: body(base.labelSmall),
    );
  }
}
