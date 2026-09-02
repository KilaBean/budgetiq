import '../../../../shared/domain/money.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../entities/budget.dart';

/// Spent-vs-allocated status for a single budgeted category.
class BudgetLine {
  const BudgetLine({required this.allocation, required this.spent});

  final BudgetAllocation allocation;
  final Money spent;

  String get categoryName => allocation.categoryName;
  Money get allocated => allocation.allocated;

  /// Allocated minus spent (may be negative when overspent).
  Money get remaining => allocated - spent;

  bool get isOverBudget => spent.minorUnits > allocated.minorUnits;

  /// Fraction of the allocation spent, clamped to [0, 1] for progress bars.
  /// Returns 1.0 when nothing is allocated but money was spent.
  double get ratio {
    if (allocated.isZero) return spent.isZero ? 0 : 1;
    return (spent.minorUnits / allocated.minorUnits).clamp(0.0, 1.0);
  }
}

/// Aggregate spent-vs-allocated view for a month's budget.
class BudgetSummary {
  const BudgetSummary({
    required this.lines,
    required this.totalAllocated,
    required this.totalSpent,
  });

  final List<BudgetLine> lines;
  final Money totalAllocated;
  final Money totalSpent;

  Money get totalRemaining => totalAllocated - totalSpent;

  double get overallRatio {
    if (totalAllocated.isZero) return totalSpent.isZero ? 0 : 1;
    return (totalSpent.minorUnits / totalAllocated.minorUnits).clamp(0.0, 1.0);
  }
}

/// Builds a [BudgetSummary] from a [budget] and the month's expense
/// [transactions]. Pure and deterministic — the unit of insight tested in
/// isolation.
BudgetSummary buildBudgetSummary({
  required Budget budget,
  required List<Transaction> monthExpenses,
}) {
  final spentByCategory = <String, Money>{};
  for (final tx in monthExpenses) {
    final categoryId = tx.categoryId;
    if (categoryId == null) continue;
    final current =
        spentByCategory[categoryId] ?? Money.zero(budget.currencyCode);
    spentByCategory[categoryId] = current + tx.amount;
  }

  final lines = budget.allocations
      .map(
        (a) => BudgetLine(
          allocation: a,
          spent:
              spentByCategory[a.expenseCategoryId] ??
              Money.zero(budget.currencyCode),
        ),
      )
      .toList();

  final totalSpent = lines.fold(
    Money.zero(budget.currencyCode),
    (sum, l) => sum + l.spent,
  );

  return BudgetSummary(
    lines: lines,
    totalAllocated: budget.totalAllocated,
    totalSpent: totalSpent,
  );
}
