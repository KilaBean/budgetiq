import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests that verify BudgetIQ's no-carryover policy:
/// each month starts fresh; prior-month unspent amounts do NOT roll forward.

Budget _budget(Month month, {double allocated = 500}) => Budget(
  id: 'b-${month.year}-${month.month}',
  month: month,
  currencyCode: 'USD',
  allocations: [
    BudgetAllocation(
      id: 'a1',
      expenseCategoryId: 'food',
      categoryName: 'Food',
      allocated: Money.fromMajor(allocated),
    ),
  ],
);

Transaction _expense(double amount, DateTime date) => Transaction(
  id: 't-$amount',
  kind: TransactionKind.expense,
  amount: Money.fromMajor(amount),
  occurredOn: date,
  categoryId: 'food',
);

void main() {
  group('Budget carryover policy — no carryover', () {
    test(
      'new month budget starts with full allocation regardless of prior month',
      () {
        const may = Month(2026, 5);
        const june = Month(2026, 6);

        final mayBudget = _budget(may, allocated: 400);
        final juneBudget = _budget(june, allocated: 400);

        // May: only spent 100 of 400 — 300 unspent.
        final maySummary = buildBudgetSummary(
          budget: mayBudget,
          monthExpenses: [_expense(100, DateTime(2026, 5, 15))],
        );
        expect(maySummary.totalRemaining, Money.fromMajor(300));

        // June budget is independent — still starts at full 400.
        final juneSummary = buildBudgetSummary(
          budget: juneBudget,
          monthExpenses: [],
        );
        expect(juneSummary.totalAllocated, Money.fromMajor(400));
        expect(juneSummary.totalSpent.isZero, isTrue);
        expect(juneSummary.totalRemaining, Money.fromMajor(400));
      },
    );

    test('prior-month expenses do not appear in new month summary', () {
      const june = Month(2026, 6);
      final budget = _budget(june);

      final summary = buildBudgetSummary(
        budget: budget,
        monthExpenses: [
          // Expenses are pre-filtered by month before being passed here —
          // the provider only passes this month's expenses.
          _expense(200, DateTime(2026, 6, 10)),
        ],
      );

      expect(summary.totalSpent, Money.fromMajor(200));
      expect(summary.totalRemaining, Money.fromMajor(300));
    });

    test('two different months produce independent Budget records', () {
      const may = Month(2026, 5);
      const june = Month(2026, 6);

      final mayBudget = _budget(may, allocated: 300);
      final juneBudget = _budget(june, allocated: 600);

      expect(mayBudget.month, isNot(juneBudget.month));
      expect(mayBudget.totalAllocated, Money.fromMajor(300));
      expect(juneBudget.totalAllocated, Money.fromMajor(600));
    });
  });
}
