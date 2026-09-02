import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/features/notifications/domain/alert_event.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetSummary _summary({
  required String catId,
  required double allocated,
  required double spent,
}) {
  final alloc = BudgetAllocation(
    id: 'a1',
    expenseCategoryId: catId,
    categoryName: 'Food',
    allocated: Money.fromMajor(allocated),
  );
  final budget = Budget(
    id: 'b1',
    month: Month.current(),
    currencyCode: 'USD',
    allocations: [alloc],
  );
  final tx = Transaction(
    id: 't1',
    kind: TransactionKind.expense,
    amount: Money.fromMajor(spent),
    occurredOn: DateTime.now(),
    categoryId: catId,
  );
  return buildBudgetSummary(
    budget: budget,
    monthExpenses: spent > 0 ? [tx] : [],
  );
}

Goal _goal({
  required double target,
  required double contributed,
  bool met = false,
}) {
  final contributions = contributed > 0
      ? [
          GoalContribution(
            id: 'c1',
            amount: Money.fromMajor(contributed),
            occurredOn: DateTime.now(),
          ),
        ]
      : <GoalContribution>[];
  return Goal(
    id: 'g1',
    name: 'Emergency Fund',
    targetAmount: Money.fromMajor(target),
    currencyCode: 'USD',
    contributions: contributions,
    status: met ? GoalStatus.met : GoalStatus.active,
  );
}

void main() {
  const period = '2026-6';

  group('buildAlertEvents', () {
    test('returns empty list when no budget and no goals', () {
      final events = buildAlertEvents(periodKey: period);
      expect(events, isEmpty);
    });

    test('no alert when spending is below threshold', () {
      final summary = _summary(catId: 'food', allocated: 100, spent: 70);
      final events = buildAlertEvents(periodKey: period, budget: summary);
      expect(events, isEmpty);
    });

    test('fires "approaching" alert at 80% threshold', () {
      final summary = _summary(catId: 'food', allocated: 100, spent: 80);
      final events = buildAlertEvents(periodKey: period, budget: summary);
      expect(events.length, 1);
      expect(events.first.key, contains('budget_near'));
      expect(events.first.title, 'Approaching budget limit');
    });

    test('fires "over budget" alert when spending exceeds allocation', () {
      final summary = _summary(catId: 'food', allocated: 100, spent: 110);
      final events = buildAlertEvents(periodKey: period, budget: summary);
      expect(events.length, 1);
      expect(events.first.key, contains('budget_over'));
      expect(events.first.title, 'Over budget');
    });

    test('over-budget alert key includes category id and period', () {
      final summary = _summary(catId: 'cat-123', allocated: 50, spent: 60);
      final events = buildAlertEvents(periodKey: '2026-6', budget: summary);
      expect(events.first.key, 'budget_over_cat-123_2026-6');
    });

    test('fires goal-met alert when goal is fully funded', () {
      final goal = _goal(target: 1000, contributed: 1000);
      final events = buildAlertEvents(periodKey: period, goals: [goal]);
      expect(events.length, 1);
      expect(events.first.key, 'goal_met_g1');
      expect(events.first.title, contains('Goal reached'));
    });

    test('no goal alert when goal is partially funded', () {
      final goal = _goal(target: 1000, contributed: 500);
      final events = buildAlertEvents(periodKey: period, goals: [goal]);
      expect(events, isEmpty);
    });

    test('skips archived goals', () {
      final goal = Goal(
        id: 'g1',
        name: 'Old Goal',
        targetAmount: Money.fromMajor(500),
        currencyCode: 'USD',
        contributions: [
          GoalContribution(
            id: 'c1',
            amount: Money.fromMajor(500),
            occurredOn: DateTime.now(),
          ),
        ],
        status: GoalStatus.archived,
      );
      final events = buildAlertEvents(periodKey: period, goals: [goal]);
      expect(events, isEmpty);
    });

    test(
      'alert keys are unique per period — same event does not duplicate',
      () {
        final summary = _summary(catId: 'food', allocated: 100, spent: 110);
        final events1 = buildAlertEvents(periodKey: '2026-6', budget: summary);
        final events2 = buildAlertEvents(periodKey: '2026-7', budget: summary);
        expect(events1.first.key, isNot(events2.first.key));
      },
    );

    test('budget alert body mentions category name and amounts', () {
      final summary = _summary(catId: 'food', allocated: 100, spent: 110);
      final events = buildAlertEvents(periodKey: period, budget: summary);
      expect(events.first.body, contains('Food'));
    });

    test('can fire both budget and goal alerts in same call', () {
      final summary = _summary(catId: 'food', allocated: 100, spent: 110);
      final goal = _goal(target: 500, contributed: 500);
      final events = buildAlertEvents(
        periodKey: period,
        budget: summary,
        goals: [goal],
      );
      expect(events.length, 2);
      expect(events.any((e) => e.key.contains('budget_over')), isTrue);
      expect(events.any((e) => e.key.contains('goal_met')), isTrue);
    });
  });
}
