import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../budgets/domain/services/budget_progress.dart';

/// How much is left to spend, and what that works out to per remaining day.
///
/// This is the number a budgeting app should lead with: "what can I spend
/// today" is the question users actually open the app to answer, where net
/// income is a report on what already happened.
class SafeToSpend {
  const SafeToSpend({
    required this.remaining,
    required this.daysLeft,
    required this.fromBudget,
    required this.isOverspent,
  });

  /// Money left for the rest of the month.
  final Money remaining;

  /// Days remaining in the month, including today. At least 1.
  final int daysLeft;

  /// Whether this came from an actual budget (rather than income minus spend).
  final bool fromBudget;

  final bool isOverspent;

  /// Even split of what is left across the days that remain.
  Money get perDay => Money(
    minorUnits: isOverspent ? 0 : remaining.minorUnits ~/ daysLeft,
    currencyCode: remaining.currencyCode,
  );
}

/// Computes [SafeToSpend] for [month] as of [now].
///
/// Prefers the budget when the user has set one — that is their own stated
/// limit — and otherwise falls back to income minus expenses so the figure
/// still means something before any budget exists.
SafeToSpend computeSafeToSpend({
  required Month month,
  required Money income,
  required Money expense,
  BudgetSummary? budget,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final usingBudget = budget != null && !budget.totalAllocated.isZero;

  final remaining = usingBudget ? budget.totalRemaining : income - expense;

  return SafeToSpend(
    remaining: remaining,
    daysLeft: _daysLeftIn(month, today),
    fromBudget: usingBudget,
    isOverspent: remaining.minorUnits < 0,
  );
}

/// Days remaining in [month] counting today, or the whole month when viewing a
/// month that has not started, or 1 for a month already past.
int _daysLeftIn(Month month, DateTime today) {
  final current = Month.fromDate(today);
  final comparison = month.compareTo(current);
  if (comparison > 0) return month.endExclusive.difference(month.start).inDays;
  if (comparison < 0) return 1;
  final lastDay = month.endExclusive.subtract(const Duration(days: 1)).day;
  final left = lastDay - today.day + 1;
  return left < 1 ? 1 : left;
}
