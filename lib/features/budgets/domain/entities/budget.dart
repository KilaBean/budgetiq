import 'package:equatable/equatable.dart';

import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';

/// A per-expense-category allocation within a monthly budget.
class BudgetAllocation extends Equatable {
  const BudgetAllocation({
    required this.id,
    required this.expenseCategoryId,
    required this.categoryName,
    required this.allocated,
    this.categoryIcon,
    this.categoryColor,
  });

  final String id;
  final String expenseCategoryId;
  final String categoryName;
  final Money allocated;
  final String? categoryIcon;
  final String? categoryColor;

  @override
  List<Object?> get props => [
    id,
    expenseCategoryId,
    categoryName,
    allocated,
    categoryIcon,
    categoryColor,
  ];
}

/// A monthly budget: the set of category allocations for one [month].
///
/// **Carryover policy: none.** Each month starts fresh with zero spending
/// against its allocations. Unused budget from a prior month does not roll
/// forward. This is an intentional YNAB-style design: allocations represent
/// a spending *plan* for the month, not an accumulating balance. Users who
/// want to save unused amounts should use a [Goal] instead.
class Budget extends Equatable {
  const Budget({
    required this.id,
    required this.month,
    required this.allocations,
    required this.currencyCode,
  });

  final String id;
  final Month month;
  final List<BudgetAllocation> allocations;
  final String currencyCode;

  /// Sum of all category allocations.
  Money get totalAllocated =>
      allocations.fold(Money.zero(currencyCode), (sum, a) => sum + a.allocated);

  @override
  List<Object?> get props => [id, month, allocations, currencyCode];
}
