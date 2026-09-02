import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/month.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/entities/health_score.dart';
import '../../domain/entities/insight.dart';
import '../../domain/services/health_score_service.dart';
import '../../domain/services/insight_rules.dart';

part 'insights_providers.g.dart';

/// Deterministic insights for the current month.
@riverpod
Future<List<Insight>> insights(Ref ref) async {
  final sources = await ref.watch(dashboardSourcesProvider.future);
  final goals = await ref.watch(goalListProvider.future);
  final budgetSummary = ref.watch(currentBudgetSummaryProvider);

  return generateInsights(
    month: Month.current(),
    income: sources.income,
    expense: sources.expense,
    budgetSummary: budgetSummary,
    goals: goals,
  );
}

/// The 0–100 financial health score with its factor breakdown.
@riverpod
Future<HealthScore> healthScore(Ref ref) async {
  final summary = await ref.watch(dashboardSummaryProvider.future);
  final trend = await ref.watch(dashboardTrendProvider.future);
  final goals = await ref.watch(goalListProvider.future);
  final budgetSummary = ref.watch(currentBudgetSummaryProvider);

  return computeHealthScore(
    savingsRate: summary.savingsRate,
    hasIncome: !summary.income.isZero,
    budgetSummary: budgetSummary,
    monthlyExpenses: trend.map((m) => m.expense).toList(),
    goals: goals,
  );
}
