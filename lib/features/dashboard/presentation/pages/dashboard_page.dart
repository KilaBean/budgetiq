import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/haptics.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../../shared/widgets/animated_amount.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../../auth/presentation/providers/auth_state_x.dart';
import '../../../budgets/presentation/pages/budgets_page.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../insights/presentation/pages/insights_page.dart';
import '../../../insights/presentation/providers/insights_providers.dart';
import '../../../insights/presentation/widgets/health_score_card.dart';
import '../../../insights/presentation/widgets/insight_tile.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_form_sheet.dart';
import '../../domain/services/dashboard_summary.dart';
import '../../domain/services/monthly_trend.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/income_expense_trend_chart.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _quickAdd(BuildContext context, WidgetRef ref) async {
    Haptics.light();
    final kind = await showModalBottomSheet<TransactionKind>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Add income'),
              onTap: () => Navigator.of(context).pop(TransactionKind.income),
            ),
            ListTile(
              leading: const Icon(Icons.trending_down),
              title: const Text('Add expense'),
              onTap: () => Navigator.of(context).pop(TransactionKind.expense),
            ),
          ],
        ),
      ),
    );
    if (kind == null || !context.mounted) return;

    final result = await showTransactionFormSheet(context, kind: kind);
    if (result == null || !context.mounted) return;
    await ref
        .read(transactionListProvider(kind).notifier)
        .create(
          amount: result.amount,
          occurredOn: result.occurredOn,
          categoryId: result.categoryId,
          note: result.note,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard',
        onPressed: () => _quickAdd(context, ref),
        child: const Icon(Icons.add),
      ),
      body: summaryAsync.when(
        loading: () => const _DashboardSkeleton(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(dashboardSourcesProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardSourcesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _Greeting(email: email, month: summary.month),
              const SizedBox(height: 16),
              _NetCard(summary: summary),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Income',
                        amount: summary.income,
                        deltaPct: summary.incomeDeltaPct,
                        higherIsGood: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Expenses',
                        amount: summary.expense,
                        deltaPct: summary.expenseDeltaPct,
                        higherIsGood: false,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(title: 'Last 6 months', child: _TrendSection()),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Spending by category',
                child: summary.topExpenseCategories.isEmpty
                    ? const _MiniEmpty(text: 'No expenses this month yet.')
                    : CategoryBreakdownChart(
                        categories: summary.topExpenseCategories,
                      ),
              ),
              const SizedBox(height: 16),
              _BudgetSnapshot(),
              const SizedBox(height: 16),
              _InsightsSnapshot(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsSnapshot extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthScoreProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        healthAsync.maybeWhen(
          data: (health) => health.factors.isEmpty
              ? const SizedBox.shrink()
              : HealthScoreCard(health: health, showFactors: false),
          orElse: () => const SizedBox.shrink(),
        ),
        insightsAsync.maybeWhen(
          data: (insights) {
            if (insights.isEmpty) return const SizedBox.shrink();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Text(
                        'Insights',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    ...insights.take(3).map((i) => InsightTile(insight: i)),
                    if (insights.length > 3)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const InsightsPage(),
                          ),
                        ),
                        child: const Text('View all insights'),
                      ),
                  ],
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.email, required this.month});

  final String? email;
  final Month month;

  @override
  Widget build(BuildContext context) {
    final name = email?.split('@').first;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name == null ? 'Welcome back' : 'Hi, $name',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          month.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _NetCard extends ConsumerWidget {
  const _NetCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final financial = theme.extension<FinancialColors>()!;
    final positive = summary.net.minorUnits >= 0;
    final trend = ref.watch(dashboardTrendProvider).value;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net this month',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedAmount(
                        amount: summary.net,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: positive
                              ? financial.income
                              : financial.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trend != null && trend.length > 1)
                  Semantics(
                    label:
                        'Net trend over the last ${trend.length} months, '
                        'ending at ${trend.last.net.format()}',
                    image: true,
                    excludeSemantics: true,
                    child: SizedBox(
                      width: 104,
                      height: 48,
                      child: _NetSparkline(series: trend),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Savings rate: ${(summary.savingsRate * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimal line spark of monthly net over the trend window.
///
/// Renders a curved line with a gradient area fill, a dashed zero baseline,
/// sign-colored fills (income green above zero, expense red below), and a dot
/// marking the latest month — coloured by whether that month was net positive.
class _NetSparkline extends StatelessWidget {
  const _NetSparkline({required this.series});

  final List<MonthlyTotals> series;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final financial = Theme.of(context).extension<FinancialColors>()!;
    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].net.major),
    ];
    final values = spots.map((s) => s.y);
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final lastPositive = spots.last.y >= 0;

    return LineChart(
      LineChartData(
        minY: math.min(0, minV) * 1.15,
        maxY: math.max(0, maxV) * 1.15,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lastPositive ? financial.income : financial.expense,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, bar) => spot.x == bar.spots.last.x,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: 3,
                color: spot.y >= 0 ? financial.income : financial.expense,
                strokeWidth: 1.5,
                strokeColor: scheme.primaryContainer,
              ),
            ),
            // Green fill between the line and zero where net is positive.
            belowBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              cutOffY: 0,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  financial.income.withValues(alpha: 0.4),
                  financial.income.withValues(alpha: 0),
                ],
              ),
            ),
            // Red fill between the line and zero where net is negative.
            aboveBarData: BarAreaData(
              show: true,
              applyCutOffY: true,
              cutOffY: 0,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  financial.expense.withValues(alpha: 0.4),
                  financial.expense.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.higherIsGood,
    this.deltaPct,
  });

  final String label;
  final Money amount;
  final double? deltaPct;
  final bool higherIsGood;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financial = theme.extension<FinancialColors>()!;
    final delta = deltaPct;
    Color? deltaColor;
    String? deltaText;
    if (delta != null) {
      final up = delta >= 0;
      final good = up == higherIsGood;
      deltaColor = good ? financial.income : financial.expense;
      deltaText = '${up ? '▲' : '▼'} ${delta.abs().round()}% vs last mo';
    }

    return Semantics(
      container: true,
      label:
          '$label: ${amount.format()}. '
          '${deltaText == null ? 'No prior month to compare' : deltaText.replaceAll('▲', 'up').replaceAll('▼', 'down')}',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              AnimatedAmount(
                amount: amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                deltaText ?? 'No prior month',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: deltaColor ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TrendSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(dashboardTrendProvider);
    return trendAsync.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const _MiniEmpty(text: 'Could not load trend.'),
      data: (series) {
        final hasData = series.any(
          (m) => !m.income.isZero || !m.expense.isZero,
        );
        if (!hasData) {
          return const _MiniEmpty(text: 'Add transactions to see your trend.');
        }
        return IncomeExpenseTrendChart(series: series);
      },
    );
  }
}

class _BudgetSnapshot extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(currentBudgetSummaryProvider);
    if (summary == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final over = summary.totalRemaining.minorUnits < 0;
    return _SectionCard(
      title: 'Budget',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${summary.totalSpent.format()} of ${summary.totalAllocated.format()}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.overallRatio,
              minHeight: 8,
              color: budgetUtilizationColor(
                context,
                summary.overallRatio,
                over: over,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder mirroring the dashboard layout while data loads.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: const [
        SkeletonBox(width: 160, height: 22),
        SizedBox(height: 20),
        SkeletonBox(height: 110, radius: 16),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
            SizedBox(width: 12),
            Expanded(child: SkeletonBox(height: 90, radius: 16)),
          ],
        ),
        SizedBox(height: 20),
        SkeletonBox(height: 240, radius: 16),
        SizedBox(height: 16),
        SkeletonBox(height: 180, radius: 16),
      ],
    );
  }
}

class _MiniEmpty extends StatelessWidget {
  const _MiniEmpty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
