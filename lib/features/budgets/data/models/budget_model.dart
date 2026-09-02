import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../domain/entities/budget.dart';

/// Maps budget rows (with embedded budget_categories → expense_categories) to
/// the [Budget] aggregate.
class BudgetModel {
  const BudgetModel._();

  static Budget fromJson(Map<String, dynamic> json, String currencyCode) {
    final currency = currencyCode;
    final periodStart = DateTime.parse(json['period_start'] as String);
    final rawCategories =
        (json['budget_categories'] as List?) ?? const <dynamic>[];

    final allocations =
        rawCategories
            .whereType<Map>()
            .map((c) => c.cast<String, dynamic>())
            // Embedded rows may include soft-deleted allocations; exclude them.
            .where((c) => c['deleted_at'] == null)
            .map((c) => _allocationFromJson(c, currency))
            .toList()
          ..sort(
            (a, b) => a.categoryName.toLowerCase().compareTo(
              b.categoryName.toLowerCase(),
            ),
          );

    return Budget(
      id: json['id'] as String,
      month: Month.fromDate(periodStart),
      currencyCode: currency,
      allocations: allocations,
    );
  }

  static BudgetAllocation _allocationFromJson(
    Map<String, dynamic> json,
    String currency,
  ) {
    final category = json['expense_categories'] is Map
        ? json['expense_categories'] as Map
        : null;
    return BudgetAllocation(
      id: json['id'] as String,
      expenseCategoryId: json['expense_category_id'] as String,
      categoryName: (category?['name'] as String?) ?? '',
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
      allocated: Money.fromDatabase(
        json['allocated_amount'] as Object,
        currencyCode: currency,
      ),
    );
  }
}
