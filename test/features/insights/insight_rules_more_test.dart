import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/features/insights/domain/entities/insight.dart';
import 'package:budgetiq/features/insights/domain/services/insight_rules.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetSummary _summary({required double allocated, required double spent}) {
  final line = BudgetLine(
    allocation: BudgetAllocation(
      id: 'a',
      expenseCategoryId: 'c',
      categoryName: 'Food',
      allocated: Money.fromMajor(allocated),
    ),
    spent: Money.fromMajor(spent),
  );
  return BudgetSummary(
    lines: [line],
    totalAllocated: Money.fromMajor(allocated),
    totalSpent: Money.fromMajor(spent),
  );
}

void main() {
  const june = Month(2026, 6);

  test('budget overspend produces a negative insight', () {
    final insights = generateInsights(
      month: june,
      income: const [],
      expense: const [],
      budgetSummary: _summary(allocated: 100, spent: 150),
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.budgetOverspend &&
            i.severity == InsightSeverity.negative &&
            i.title.contains('Food'),
      ),
      isTrue,
    );
  });

  test('within budget produces a positive insight', () {
    final insights = generateInsights(
      month: june,
      income: const [],
      expense: const [],
      budgetSummary: _summary(allocated: 200, spent: 80),
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.budgetOverspend &&
            i.severity == InsightSeverity.positive,
      ),
      isTrue,
    );
  });

  test('met goal yields a positive insight; in-progress yields neutral', () {
    final met = Goal(
      id: 'g1',
      name: 'Emergency',
      targetAmount: Money.fromMajor(100),
      currencyCode: 'USD',
      contributions: [
        GoalContribution(
          id: 'c1',
          amount: Money.fromMajor(100),
          occurredOn: DateTime(2026, 5, 1),
        ),
      ],
    );
    final inProgress = Goal(
      id: 'g2',
      name: 'Laptop',
      targetAmount: Money.fromMajor(1000),
      currencyCode: 'USD',
      contributions: [
        GoalContribution(
          id: 'c2',
          amount: Money.fromMajor(200),
          occurredOn: DateTime(2026, 5, 1),
        ),
      ],
    );

    final insights = generateInsights(
      month: june,
      income: const [],
      expense: const [],
      goals: [met, inProgress],
    );

    expect(
      insights.any(
        (i) =>
            i.type == InsightType.goalProgress &&
            i.severity == InsightSeverity.positive &&
            i.title.contains('Emergency'),
      ),
      isTrue,
    );
    expect(
      insights.any(
        (i) =>
            i.type == InsightType.goalProgress &&
            i.severity == InsightSeverity.neutral &&
            i.title.contains('Laptop'),
      ),
      isTrue,
    );
  });
}
