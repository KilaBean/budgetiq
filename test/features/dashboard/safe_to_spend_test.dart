import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/dashboard/domain/services/safe_to_spend.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetSummary _budget({required double allocated, required double spent}) =>
    BudgetSummary(
      lines: [
        BudgetLine(
          allocation: BudgetAllocation(
            id: 'a1',
            expenseCategoryId: 'c1',
            categoryName: 'Food',
            allocated: Money.fromMajor(allocated),
          ),
          spent: Money.fromMajor(spent),
        ),
      ],
      totalAllocated: Money.fromMajor(allocated),
      totalSpent: Money.fromMajor(spent),
    );

void main() {
  final june = Month(2026, 6); // 30 days
  final midMonth = DateTime(2026, 6, 21); // 10 days left, inclusive

  group('with a budget', () {
    test('remaining comes from the budget, not from income', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(5000),
        expense: Money.fromMajor(400),
        budget: _budget(allocated: 1000, spent: 400),
        now: midMonth,
      );

      expect(safe.fromBudget, isTrue);
      expect(safe.remaining, Money.fromMajor(600));
      expect(safe.isOverspent, isFalse);
    });

    test('splits what is left across the days that remain', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(5000),
        expense: Money.fromMajor(400),
        budget: _budget(allocated: 1000, spent: 400),
        now: midMonth,
      );

      expect(safe.daysLeft, 10);
      expect(safe.perDay, Money.fromMajor(60));
    });

    test('overspending reports zero per day rather than a negative rate', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(5000),
        expense: Money.fromMajor(1200),
        budget: _budget(allocated: 1000, spent: 1200),
        now: midMonth,
      );

      expect(safe.isOverspent, isTrue);
      expect(safe.remaining, Money.fromMajor(-200));
      expect(safe.perDay, Money.zero());
    });

    test('an empty budget falls back to income minus spend', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(3000),
        expense: Money.fromMajor(1000),
        budget: BudgetSummary(
          lines: const [],
          totalAllocated: Money.zero(),
          totalSpent: Money.zero(),
        ),
        now: midMonth,
      );

      expect(safe.fromBudget, isFalse);
      expect(safe.remaining, Money.fromMajor(2000));
    });
  });

  group('without a budget', () {
    test('remaining is income minus expenses', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(3000),
        expense: Money.fromMajor(1800),
        now: midMonth,
      );

      expect(safe.fromBudget, isFalse);
      expect(safe.remaining, Money.fromMajor(1200));
      expect(safe.perDay, Money.fromMajor(120));
    });
  });

  group('days left', () {
    test('counts today, so the last day of the month still has one', () {
      final safe = computeSafeToSpend(
        month: june,
        income: Money.fromMajor(100),
        expense: Money.zero(),
        now: DateTime(2026, 6, 30),
      );

      expect(safe.daysLeft, 1);
      expect(safe.perDay, Money.fromMajor(100));
    });

    test('a past month is not divided across days it no longer has', () {
      final safe = computeSafeToSpend(
        month: Month(2026, 5),
        income: Money.fromMajor(100),
        expense: Money.zero(),
        now: midMonth,
      );

      expect(safe.daysLeft, 1);
    });

    test('a future month gets its whole length', () {
      final safe = computeSafeToSpend(
        month: Month(2026, 7), // 31 days
        income: Money.fromMajor(310),
        expense: Money.zero(),
        now: midMonth,
      );

      expect(safe.daysLeft, 31);
      expect(safe.perDay, Money.fromMajor(10));
    });
  });
}
