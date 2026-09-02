import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../providers/insights_providers.dart';
import '../widgets/health_score_card.dart';
import '../widgets/insight_tile.dart';

/// Full insights screen: health score breakdown plus all current insights.
class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthScoreProvider);
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSourcesProvider);
          ref.invalidate(goalListProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            healthAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorView(error: e),
              data: (health) => HealthScoreCard(health: health),
            ),
            const SizedBox(height: 20),
            Text(
              'What we noticed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            insightsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => ErrorView(error: e),
              data: (insights) {
                if (insights.isEmpty) {
                  return const EmptyState(
                    icon: Icons.insights_outlined,
                    title: 'No insights yet',
                    message:
                        'Add income, expenses and a budget, and BudgetIQ will '
                        'surface patterns here.',
                  );
                }
                return Column(
                  children: insights
                      .map((i) => InsightTile(insight: i))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
