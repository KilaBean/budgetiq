import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/features/notifications/domain/alert_event.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetSummary _summary({required double allocated, required double spent}) {
  final line = BudgetLine(
    allocation: BudgetAllocation(
      id: 'a',
      expenseCategoryId: 'food',
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
  test('over-budget produces a scoped over event', () {
    final events = buildAlertEvents(
      periodKey: '2026-6',
      budget: _summary(allocated: 100, spent: 150),
    );
    expect(events.single.key, 'budget_over_food_2026-6');
    expect(events.single.title, 'Over budget');
  });

  test('nearing limit (>=80%) produces a near event', () {
    final events = buildAlertEvents(
      periodKey: '2026-6',
      budget: _summary(allocated: 100, spent: 85),
    );
    expect(events.single.key, 'budget_near_food_2026-6');
  });

  test('well under budget produces no event', () {
    final events = buildAlertEvents(
      periodKey: '2026-6',
      budget: _summary(allocated: 100, spent: 40),
    );
    expect(events, isEmpty);
  });

  test('met goal produces a goal event', () {
    final goal = Goal(
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
    final events = buildAlertEvents(periodKey: '2026-6', goals: [goal]);
    expect(events.single.key, 'goal_met_g1');
  });
}
