import 'package:budgetiq/features/budgets/domain/entities/budget.dart';
import 'package:budgetiq/features/budgets/domain/services/budget_progress.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetAllocation _alloc(String catId, String name, double amount) =>
    BudgetAllocation(
      id: 'a-$catId',
      expenseCategoryId: catId,
      categoryName: name,
      allocated: Money.fromMajor(amount),
    );

Transaction _expense(String catId, double amount) => Transaction(
  id: 't-$catId-$amount',
  kind: TransactionKind.expense,
  amount: Money.fromMajor(amount),
  occurredOn: DateTime(2026, 6, 10),
  categoryId: catId,
);

void main() {
  final budget = Budget(
    id: 'b1',
    month: const Month(2026, 6),
    currencyCode: 'USD',
    allocations: [
      _alloc('food', 'Food', 400),
      _alloc('transport', 'Transport', 100),
    ],
  );

  test('aggregates spent per category and overall', () {
    final summary = buildBudgetSummary(
      budget: budget,
      monthExpenses: [
        _expense('food', 150),
        _expense('food', 100),
        _expense('transport', 40),
      ],
    );

    final food = summary.lines.firstWhere((l) => l.categoryName == 'Food');
    expect(food.spent, Money.fromMajor(250));
    expect(food.remaining, Money.fromMajor(150));
    expect(food.isOverBudget, isFalse);

    expect(summary.totalAllocated, Money.fromMajor(500));
    expect(summary.totalSpent, Money.fromMajor(290));
    expect(summary.totalRemaining, Money.fromMajor(210));
  });

  test('flags overspending and clamps ratio at 1', () {
    final summary = buildBudgetSummary(
      budget: budget,
      monthExpenses: [_expense('transport', 130)],
    );
    final transport = summary.lines.firstWhere(
      (l) => l.categoryName == 'Transport',
    );
    expect(transport.isOverBudget, isTrue);
    expect(transport.ratio, 1.0);
    expect(transport.remaining, Money.fromMajor(-30));
  });

  test('uncategorized expenses are ignored', () {
    final summary = buildBudgetSummary(
      budget: budget,
      monthExpenses: [
        Transaction(
          id: 'x',
          kind: TransactionKind.expense,
          amount: Money.fromMajor(99),
          occurredOn: DateTime(2026, 6, 1),
        ),
      ],
    );
    expect(summary.totalSpent.isZero, isTrue);
  });
}
