import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/goal.dart';
import '../../domain/services/goal_projection.dart';
import '../providers/goal_providers.dart';
import '../widgets/contribution_form_sheet.dart';
import '../widgets/goal_projection_text.dart';

class GoalDetailPage extends ConsumerWidget {
  const GoalDetailPage({super.key, required this.goalId});

  final String goalId;

  Future<void> _addContribution(BuildContext context, WidgetRef ref) async {
    final result = await showContributionFormSheet(context);
    if (result == null || !context.mounted) return;
    await _run(context, () async {
      await ref
          .read(goalListProvider.notifier)
          .addContribution(
            goalId: goalId,
            amount: result.amount,
            occurredOn: result.occurredOn,
            note: result.note,
          );
    });
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    await _run(context, () async {
      await ref.read(goalListProvider.notifier).remove(goal);
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
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
    final goal = ref.watch(goalByIdProvider(goalId));

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.flag_outlined,
          title: 'Goal unavailable',
          message: 'This goal may have been deleted.',
        ),
      );
    }

    final projection = projectGoal(goal);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete goal',
            onPressed: () => _confirmDelete(context, ref, goal),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_goal_detail',
        onPressed: () => _addContribution(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Contribute'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _GoalHeader(goal: goal, projection: projection),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Contributions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (goal.contributions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No contributions yet. Add your first one.'),
            )
          else
            ...goal.contributions.map(
              (c) => Dismissible(
                key: ValueKey(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete_outline),
                ),
                confirmDismiss: (_) async {
                  await _run(
                    context,
                    () => ref
                        .read(goalListProvider.notifier)
                        .removeContribution(c.id),
                  );
                  return false;
                },
                child: ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: Text(c.amount.format()),
                  subtitle: Text(
                    [
                      DateFormat.yMMMd().format(c.occurredOn),
                      if (c.note?.isNotEmpty ?? false) c.note!,
                    ].join(' · '),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Goal goal,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('“${goal.name}” and its contributions will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await _deleteGoal(context, ref, goal);
    }
  }
}

class _GoalHeader extends StatelessWidget {
  const _GoalHeader({required this.goal, required this.projection});

  final Goal goal;
  final GoalProjection projection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${goal.contributed.format()} of ${goal.targetAmount.format()}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // The amounts above and the projection below already say it; the bar
          // itself would just add an unlabelled node.
          Semantics(
            label:
                '${(projection.progressRatio * 100).round()} percent of target',
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: projection.progressRatio,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                projection.isMet ? Icons.check_circle : Icons.timeline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(goalProjectionMessage(projection))),
            ],
          ),
          if (goal.targetDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'Target date: ${DateFormat.yMMMd().format(goal.targetDate!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
