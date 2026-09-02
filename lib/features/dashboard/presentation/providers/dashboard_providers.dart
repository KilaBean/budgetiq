import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../domain/services/dashboard_summary.dart';
import '../../domain/services/safe_to_spend.dart';
import 'selected_month_provider.dart';
import '../../domain/services/monthly_trend.dart';

part 'dashboard_providers.g.dart';

/// Combined loading/error state of the dashboard's underlying data sources.
typedef DashboardSources = ({
  List<Transaction> income,
  List<Transaction> expense,
});

/// Resolves the income + expense lists, surfacing loading/error as an
/// AsyncValue so the dashboard can render the right state.
@riverpod
Future<DashboardSources> dashboardSources(Ref ref) async {
  final income = await ref.watch(
    transactionListProvider(TransactionKind.income).future,
  );
  final expense = await ref.watch(
    transactionListProvider(TransactionKind.expense).future,
  );
  return (income: income.items, expense: expense.items);
}

/// Headline summary for the selected month.
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) async {
  final sources = await ref.watch(dashboardSourcesProvider.future);
  return buildDashboardSummary(
    month: ref.watch(selectedMonthProvider),
    income: sources.income,
    expense: sources.expense,
    currencyCode: ref.watch(currencyCodeProvider),
  );
}

/// Last-6-months income vs expense trend.
@riverpod
Future<List<MonthlyTotals>> dashboardTrend(Ref ref) async {
  final sources = await ref.watch(dashboardSourcesProvider.future);
  return buildMonthlyTrend(
    income: sources.income,
    expense: sources.expense,
    currencyCode: ref.watch(currencyCodeProvider),
  );
}

/// The headline "what can I still spend" figure for the selected month.
@riverpod
Future<SafeToSpend> safeToSpend(Ref ref) async {
  final summary = await ref.watch(dashboardSummaryProvider.future);
  return computeSafeToSpend(
    month: ref.watch(selectedMonthProvider),
    income: summary.income,
    expense: summary.expense,
    budget: ref.watch(currentBudgetSummaryProvider),
  );
}
