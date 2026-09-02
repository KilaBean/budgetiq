import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../domain/entities/goal.dart';
import '../../domain/services/goal_projection.dart';
import '../providers/goal_providers.dart';
import '../widgets/goal_form_sheet.dart';
import '../widgets/goal_projection_text.dart';
import 'goal_detail_page.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  Future<void> _createGoal(BuildContext context, WidgetRef ref) async {
    final result = await showGoalFormSheet(context);
    if (result == null) return;
    try {
      await ref
          .read(goalListProvider.notifier)
          .create(
            name: result.name,
            targetAmount: result.targetAmount,
            targetDate: result.targetDate,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(messageFromError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_goals',
        onPressed: () => _createGoal(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goalsAsync.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(goalListProvider),
        ),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: 'No goals yet',
              message:
                  'Create a savings goal and track your progress over time.',
              actionLabel: 'New goal',
              onAction: () => _createGoal(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(goalListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: goals.length,
              itemBuilder: (context, i) => _GoalCard(goal: goals[i]),
            ),
          );
        },
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projection = projectGoal(goal);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GoalDetailPage(goalId: goal.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Semantics(
            container: true,
            button: true,
            label:
                '${goal.name}: ${goal.contributed.format()} saved of '
                '${goal.targetAmount.format()}, '
                '${(projection.progressRatio * 100).round()} percent. '
                '${goalProjectionMessage(projection)}',
            excludeSemantics: true,
            child: Row(
              children: [
                _ProgressRing(value: projection.progressRatio),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${goal.contributed.format()} of ${goal.targetAmount.format()}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goalProjectionMessage(projection),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring with the percentage in the center.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
