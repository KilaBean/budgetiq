import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/month.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/services/dashboard_summary.dart';
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

/// Current-month dashboard headline summary.
@riverpod
Future<DashboardSummary> dashboardSummary(Ref ref) async {
  final sources = await ref.watch(dashboardSourcesProvider.future);
  return buildDashboardSummary(
    month: Month.current(),
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
