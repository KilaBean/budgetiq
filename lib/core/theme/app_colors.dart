import 'package:flutter/material.dart';

/// Brand color tokens for BudgetIQ.
///
/// Semantic financial colors (income/expense) are kept separate from the
/// Material seed so they remain stable across light/dark schemes.
class AppColors {
  const AppColors._();

  /// Primary brand seed — a confident fintech teal/green.
  static const Color seed = Color(0xFF1FB58F);

  /// Positive cash flow (income, gains, on-track goals).
  static const Color income = Color(0xFF1FB58F);

  /// Negative cash flow (expenses, overspend).
  static const Color expense = Color(0xFFE5484D);

  /// Caution / approaching budget limit.
  static const Color warning = Color(0xFFF2A30F);
}

/// Semantic financial colors exposed via [ThemeExtension] so widgets can read
/// income/expense colors from the theme rather than importing [AppColors]
/// directly.
@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  const FinancialColors({
    required this.income,
    required this.expense,
    required this.warning,
  });

  final Color income;
  final Color expense;
  final Color warning;

  static const light = FinancialColors(
    income: AppColors.income,
    expense: AppColors.expense,
    warning: AppColors.warning,
  );

  static const dark = FinancialColors(
    income: Color(0xFF3DD9B0),
    expense: Color(0xFFFF6166),
    warning: Color(0xFFFFC04D),
  );

  @override
  FinancialColors copyWith({Color? income, Color? expense, Color? warning}) {
    return FinancialColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      warning: warning ?? this.warning,
    );
  }

  @override
  FinancialColors lerp(ThemeExtension<FinancialColors>? other, double t) {
    if (other is! FinancialColors) return this;
    return FinancialColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
