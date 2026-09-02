import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../entities/budget.dart';

/// Contract for monthly budgets. Implementations throw a
/// [Failure](../../../../core/error/failure.dart) on error.
abstract interface class BudgetRepository {
  /// The budget for [month], or `null` if none has been created yet.
  Future<Budget?> getBudget(Month month);

  /// Sets (creates or updates) the allocation for an expense category in
  /// [month], creating the month's budget on first use. Returns the refreshed
  /// budget.
  Future<Budget> setAllocation({
    required Month month,
    required String expenseCategoryId,
    required Money amount,
  });

  /// Removes a category allocation from its budget.
  Future<void> removeAllocation(BudgetAllocation allocation);
}
