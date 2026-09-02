import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the currentBudgetSummary provider computation logic.
/// Tests the pure buildBudgetSummary function combined with the month filter
/// that the provider applies before calling it.

BudgetAllocation _alloc(String catId, String name, double amount) =>
    BudgetAllocation(
      id: 'a-$catId',
      expenseCategoryId: catId,
      categoryName: name,
      allocated: Money.fromMajor(amount),
    );

Transaction _expense(String catId, double amount, DateTime date) => Transaction(
  id: 't-$catId-$amount',
  kind: TransactionKind.expense,
  amount: Money.fromMajor(amount),
  occurredOn: date,
  categoryId: catId,
);

BudgetSummary _summarize(Budget budget, List<Transaction> allExpenses) {
  final month = budget.month;
  final monthExpenses = allExpenses
      .where((t) => month.contains(t.occurredOn))
      .toList();
  return buildBudgetSummary(budget: budget, monthExpenses: monthExpenses);
}

void main() {
  final june = const Month(2026, 6);
  final budget = Budget(
    id: 'b1',
    month: june,
    currencyCode: 'USD',
    allocations: [
      _alloc('food', 'Food', 400),
      _alloc('transport', 'Transport', 100),
    ],
  );

  group('currentBudgetSummary provider logic', () {
    test('returns zero spent when no expenses exist', () {
      final summary = _summarize(budget, []);
      expect(summary.totalSpent.isZero, isTrue);
      expect(summary.totalAllocated, Money.fromMajor(500));
      expect(summary.totalRemaining, Money.fromMajor(500));
    });

    test('filters out prior-month expenses', () {
      final summary = _summarize(budget, [
        _expense('food', 100, DateTime(2026, 5, 31)),
        _expense('food', 200, DateTime(2026, 6, 1)),
      ]);
      expect(summary.totalSpent, Money.fromMajor(200));
    });

    test('filters out next-month expenses', () {
      final summary = _summarize(budget, [
        _expense('food', 300, DateTime(2026, 6, 30)),
        _expense('food', 150, DateTime(2026, 7, 1)),
      ]);
      expect(summary.totalSpent, Money.fromMajor(300));
    });

    test('aggregates multiple expenses for same category', () {
      final summary = _summarize(budget, [
        _expense('food', 100, DateTime(2026, 6, 5)),
        _expense('food', 50, DateTime(2026, 6, 10)),
        _expense('food', 25, DateTime(2026, 6, 20)),
      ]);
      final foodLine = summary.lines.firstWhere(
        (l) => l.categoryName == 'Food',
      );
      expect(foodLine.spent, Money.fromMajor(175));
      expect(foodLine.isOverBudget, isFalse);
    });

    test('marks category as over budget', () {
      final summary = _summarize(budget, [
        _expense('transport', 150, DateTime(2026, 6, 1)),
      ]);
      final line = summary.lines.firstWhere(
        (l) => l.categoryName == 'Transport',
      );
      expect(line.isOverBudget, isTrue);
      expect(line.remaining, Money.fromMajor(-50));
      expect(line.ratio, 1.0);
    });

    test('summary has a line per allocation even with no spending', () {
      final summary = _summarize(budget, []);
      expect(summary.lines.length, 2);
      expect(summary.lines.every((l) => l.spent.isZero), isTrue);
    });
  });
}
