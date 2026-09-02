import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../budgets/domain/services/budget_progress.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/services/goal_projection.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/insight.dart';

/// Thresholds keep the rules explainable and tunable in one place.
const double _materialChangePct = 10; // ignore noise below this
const double _categoryChangePct = 15;
const int _trendMonths = 3; // consecutive months for a trend insight
const double _goodSavingsRate = 0.20;

/// Generates deterministic, explainable insights from the user's data for
/// [month]. No AI — every insight maps directly to a rule below.
List<Insight> generateInsights({
  required Month month,
  required List<Transaction> income,
  required List<Transaction> expense,
  BudgetSummary? budgetSummary,
  List<Goal> goals = const [],
}) {
  final insights = <Insight>[
    ..._savingsRateInsight(month, income, expense),
    ..._overallSpendInsight(month, expense),
    ..._categoryChangeInsights(month, expense),
    ..._categoryTrendInsights(month, expense),
    ..._budgetInsights(budgetSummary),
    ..._goalInsights(goals),
  ];

  // Most actionable first: negative, warning, positive, neutral.
  const order = {
    InsightSeverity.negative: 0,
    InsightSeverity.warning: 1,
    InsightSeverity.positive: 2,
    InsightSeverity.neutral: 3,
  };
  insights.sort((a, b) => order[a.severity]!.compareTo(order[b.severity]!));
  return insights;
}

// --- rules -----------------------------------------------------------------

List<Insight> _savingsRateInsight(
  Month month,
  List<Transaction> income,
  List<Transaction> expense,
) {
  final inc = _sum(income, month);
  final exp = _sum(expense, month);
  if (inc.isZero && exp.isZero) return const [];

  if (inc.isZero || exp.minorUnits >= inc.minorUnits) {
    return [
      const Insight(
        type: InsightType.savingsRate,
        severity: InsightSeverity.negative,
        title: 'Spending exceeded income',
        message:
            'You spent as much or more than you earned this month. Consider '
            'trimming a category to get back in the black.',
      ),
    ];
  }

  final rate = (inc.minorUnits - exp.minorUnits) / inc.minorUnits;
  if (rate >= _goodSavingsRate) {
    return [
      Insight(
        type: InsightType.savingsRate,
        severity: InsightSeverity.positive,
        title: 'Strong savings rate',
        message:
            'You saved ${(rate * 100).round()}% of your income this month. '
            'Keep it up!',
      ),
    ];
  }
  return const [];
}

List<Insight> _overallSpendInsight(Month month, List<Transaction> expense) {
  final current = _sum(expense, month);
  final previous = _sum(expense, month.previous);
  final pct = _pctChange(previous, current);
  if (pct == null || pct.abs() < _materialChangePct) return const [];

  final up = pct > 0;
  return [
    Insight(
      type: InsightType.spendingChange,
      severity: up ? InsightSeverity.warning : InsightSeverity.positive,
      title: up ? 'Spending up this month' : 'Spending down this month',
      message:
          'Your total spending is ${pct.abs().round()}% '
          '${up ? 'higher' : 'lower'} than last month.',
    ),
  ];
}

List<Insight> _categoryChangeInsights(Month month, List<Transaction> expense) {
  final current = _byCategory(expense, month);
  final previous = _byCategory(expense, month.previous);

  final increases = <({String name, double pct})>[];
  for (final entry in current.entries) {
    final prev = previous[entry.key];
    if (prev == null || prev.isZero) continue;
    final pct = _pctChange(prev, entry.value)!;
    if (pct >= _categoryChangePct) {
      increases.add((name: entry.key, pct: pct));
    }
  }
  increases.sort((a, b) => b.pct.compareTo(a.pct));

  return increases
      .take(2)
      .map(
        (c) => Insight(
          type: InsightType.spendingChange,
          severity: InsightSeverity.warning,
          title: 'More spent on ${c.name}',
          message:
              'You spent ${c.pct.round()}% more on ${c.name} this month '
              'than last month.',
        ),
      )
      .toList();
}

List<Insight> _categoryTrendInsights(Month month, List<Transaction> expense) {
  // Look at the last (_trendMonths + 1) months so we can detect a strictly
  // increasing run of _trendMonths steps.
  final months = <Month>[];
  var cursor = month;
  for (var i = 0; i <= _trendMonths; i++) {
    months.insert(0, cursor);
    cursor = cursor.previous;
  }

  final categories = expense
      .map((t) => t.categoryName ?? 'Uncategorized')
      .toSet();

  final results = <Insight>[];
  for (final name in categories) {
    final series = months
        .map(
          (m) => _sum(
            expense.where((t) => (t.categoryName ?? 'Uncategorized') == name),
            m,
          ).minorUnits,
        )
        .toList();

    var increasing = true;
    for (var i = 1; i < series.length; i++) {
      if (series[i] <= series[i - 1]) {
        increasing = false;
        break;
      }
    }
    if (increasing && series.first >= 0) {
      results.add(
        Insight(
          type: InsightType.spendingTrend,
          severity: InsightSeverity.warning,
          title: '$name keeps rising',
          message:
              '$name has increased for $_trendMonths months in a row. Worth '
              'a closer look.',
        ),
      );
    }
  }
  return results;
}

List<Insight> _budgetInsights(BudgetSummary? summary) {
  if (summary == null || summary.lines.isEmpty) return const [];

  final over = summary.lines.where((l) => l.isOverBudget).toList()
    ..sort(
      (a, b) => (b.spent - b.allocated).minorUnits.compareTo(
        (a.spent - a.allocated).minorUnits,
      ),
    );

  if (over.isNotEmpty) {
    final line = over.first;
    return [
      Insight(
        type: InsightType.budgetOverspend,
        severity: InsightSeverity.negative,
        title: 'Over budget on ${line.categoryName}',
        message:
            'You\'ve spent ${line.spent.format()} of your '
            '${line.allocated.format()} ${line.categoryName} budget.',
      ),
    ];
  }

  return [
    Insight(
      type: InsightType.budgetOverspend,
      severity: InsightSeverity.positive,
      title: 'On budget',
      message:
          'You\'re within budget across all categories — '
          '${summary.totalRemaining.format()} left this month.',
    ),
  ];
}

List<Insight> _goalInsights(List<Goal> goals) {
  final results = <Insight>[];
  for (final goal in goals) {
    if (goal.status == GoalStatus.archived) continue;
    final p = projectGoal(goal);
    if (p.isMet) {
      results.add(
        Insight(
          type: InsightType.goalProgress,
          severity: InsightSeverity.positive,
          title: '${goal.name} reached',
          message: 'You\'ve hit your ${goal.name} target. 🎉',
        ),
      );
    } else if (p.monthsToTarget != null) {
      results.add(
        Insight(
          type: InsightType.goalProgress,
          severity: InsightSeverity.neutral,
          title: '${goal.name} on track',
          message:
              'At your current pace, ${goal.name} will be reached in about '
              '${p.monthsToTarget} month${p.monthsToTarget == 1 ? '' : 's'}.',
        ),
      );
    }
  }
  return results;
}

// --- helpers ---------------------------------------------------------------

Money _sum(Iterable<Transaction> txns, Month month) {
  Money? total;
  for (final t in txns.where((t) => month.contains(t.occurredOn))) {
    total = total == null ? t.amount : total + t.amount;
  }
  return total ?? Money.zero();
}

Map<String, Money> _byCategory(List<Transaction> expense, Month month) {
  final map = <String, Money>{};
  for (final t in expense.where((t) => month.contains(t.occurredOn))) {
    final name = t.categoryName ?? 'Uncategorized';
    map[name] = (map[name] ?? Money.zero(t.amount.currencyCode)) + t.amount;
  }
  return map;
}

double? _pctChange(Money previous, Money current) {
  if (previous.isZero) return null;
  return (current.minorUnits - previous.minorUnits) / previous.minorUnits * 100;
}
