import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/features/insights/domain/services/health_score_service.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetSummary _summary({required double allocated, required double spent}) {
  return BudgetSummary(
    lines: [
      BudgetLine(
        allocation: BudgetAllocation(
          id: 'a',
          expenseCategoryId: 'c',
          categoryName: 'Food',
          allocated: Money.fromMajor(allocated),
        ),
        spent: Money.fromMajor(spent),
      ),
    ],
    totalAllocated: Money.fromMajor(allocated),
    totalSpent: Money.fromMajor(spent),
  );
}

void main() {
  test('empty inputs yield a zero score with no factors', () {
    final score = computeHealthScore(savingsRate: 0, hasIncome: false);
    expect(score.score, 0);
    expect(score.factors, isEmpty);
  });

  test('high savings + on-budget produces a high score', () {
    final score = computeHealthScore(
      savingsRate: 0.30, // exceeds 20% target → full marks
      hasIncome: true,
      budgetSummary: _summary(allocated: 1000, spent: 800),
      monthlyExpenses: [Money.fromMajor(500), Money.fromMajor(510)],
    );
    expect(score.score, greaterThanOrEqualTo(80));
    expect(score.band, anyOf('Excellent', 'Good'));
    // Each applicable factor is explained.
    expect(score.factors.every((f) => f.explanation.isNotEmpty), isTrue);
  });

  test('overspending lowers the budget-adherence factor', () {
    final score = computeHealthScore(
      savingsRate: 0.30,
      hasIncome: true,
      budgetSummary: _summary(allocated: 1000, spent: 1500), // 50% over
    );
    final budgetFactor = score.factors.firstWhere(
      (f) => f.name == 'Budget adherence',
    );
    expect(budgetFactor.score, closeTo(0.5, 0.0001));
  });

  test('only applicable factors are weighted (normalization)', () {
    // Only savings applies; score should reflect savings alone.
    final score = computeHealthScore(savingsRate: 0.10, hasIncome: true);
    expect(score.factors.length, 1);
    // 0.10 / 0.20 target = 0.5 → 50.
    expect(score.score, 50);
  });

  test('goal progress factor averages active goals', () {
    final goal = Goal(
      id: 'g',
      name: 'Fund',
      targetAmount: Money.fromMajor(1000),
      currencyCode: 'USD',
      contributions: [
        GoalContribution(
          id: 'c1',
          amount: Money.fromMajor(500),
          occurredOn: DateTime(2026, 6, 1),
        ),
      ],
    );
    final score = computeHealthScore(
      savingsRate: 0,
      hasIncome: false,
      goals: [goal],
    );
    final goalFactor = score.factors.firstWhere(
      (f) => f.name == 'Goal progress',
    );
    expect(goalFactor.score, closeTo(0.5, 0.0001));
  });
}
