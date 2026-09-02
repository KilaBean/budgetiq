import 'package:supabase_flutter/supabase_flutter.dart';

/// Read access to budgets and their category allocations.
///
/// Writes go through the offline sync outbox (see core/sync), not this class,
/// so only the read path lives here.
class BudgetRemoteDataSource {
  BudgetRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _budgetSelect =
      'id, period_start, currency_code, total_amount, '
      'budget_categories(id, expense_category_id, allocated_amount, '
      'updated_at, deleted_at, expense_categories(name, icon, color))';

  /// Fetches the budget (with allocations) for [periodStart], or `null`.
  Future<Map<String, dynamic>?> fetchBudget(String periodStart) async {
    return _client
        .from('budgets')
        .select(_budgetSelect)
        .eq('period_start', periodStart)
        .isFilter('deleted_at', null)
        .maybeSingle();
  }
}
