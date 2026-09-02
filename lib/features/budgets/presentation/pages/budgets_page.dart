import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/month.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/budget.dart';
import '../../domain/services/budget_progress.dart';
import '../providers/budget_providers.dart';
import '../widgets/allocation_form_sheet.dart';

/// Green under 80% utilization, amber 80–100%, red when over budget.
Color budgetUtilizationColor(
  BuildContext context,
  double ratio, {
  required bool over,
}) {
  final theme = Theme.of(context);
  if (over) return theme.colorScheme.error;
  if (ratio >= 0.8) return theme.extension<FinancialColors>()!.warning;
  return theme.colorScheme.primary;
}

class BudgetsPage extends ConsumerWidget {
  const BudgetsPage({super.key});

  Future<void> _addAllocation(BuildContext context, WidgetRef ref) async {
    final result = await showAllocationFormSheet(context);
    if (result == null || !context.mounted) return;
    await _save(context, ref, result);
  }

  Future<void> _editAllocation(
    BuildContext context,
    WidgetRef ref,
    BudgetAllocation allocation,
  ) async {
    final result = await showAllocationFormSheet(
      context,
      fixedCategoryId: allocation.expenseCategoryId,
      initialAmount: allocation.allocated.major,
    );
    if (result == null || !context.mounted) return;
    await _save(context, ref, result);
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    AllocationFormResult result,
  ) async {
    try {
      await ref
          .read(currentBudgetProvider.notifier)
          .setAllocation(
            expenseCategoryId: result.expenseCategoryId,
            amount: result.amount,
          );
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    BudgetAllocation allocation,
  ) async {
    try {
      await ref
          .read(currentBudgetProvider.notifier)
          .removeAllocation(allocation);
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(messageFromError(error))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(currentBudgetProvider);
    final summary = ref.watch(currentBudgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Budget · ${Month.current().label}')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budgets',
        onPressed: () => _addAllocation(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Allocate'),
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(currentBudgetProvider),
        ),
        data: (budget) {
          if (budget == null || budget.allocations.isEmpty || summary == null) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No budget set',
              message:
                  'Allocate a monthly amount to your expense categories to '
                  'start tracking spending against plan.',
              actionLabel: 'Add allocation',
              onAction: () => _addAllocation(context, ref),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _BudgetOverviewCard(summary: summary),
              const SizedBox(height: 8),
              ...summary.lines.map(
                (line) => _BudgetLineTile(
                  line: line,
                  onTap: () => _editAllocation(context, ref, line.allocation),
                  onDelete: () => _remove(context, ref, line.allocation),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetOverviewCard extends StatelessWidget {
  const _BudgetOverviewCard({required this.summary});

  final BudgetSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final over = summary.totalRemaining.minorUnits < 0;
    return Card(
      color: scheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spent this month',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${summary.totalSpent.format()} of ${summary.totalAllocated.format()}',
                maxLines: 1,
                softWrap: false,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.overallRatio,
                  minHeight: 10,
                  backgroundColor: scheme.onPrimaryContainer.withValues(
                    alpha: 0.15,
                  ),
                  color: budgetUtilizationColor(
                    context,
                    summary.overallRatio,
                    over: over,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              over
                  ? '${(summary.totalSpent - summary.totalAllocated).format()} over budget'
                  : '${summary.totalRemaining.format()} remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: over
                    ? scheme.error
                    : scheme.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetLineTile extends StatelessWidget {
  const _BudgetLineTile({
    required this.line,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetLine line;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = line.isOverBudget;
    final barColor = budgetUtilizationColor(context, line.ratio, over: over);
    return Dismissible(
      key: ValueKey(line.allocation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Semantics(
        container: true,
        button: true,
        label:
            '${line.categoryName}: ${line.spent.format()} spent of '
            '${line.allocated.format()} allocated, '
            '${(line.ratio * 100).round()} percent'
            '${over ? ', over budget' : ''}',
        excludeSemantics: true,
        child: ListTile(
          onTap: onTap,
          leading: CategoryAvatar(
            iconName: line.allocation.categoryIcon,
            colorHex: line.allocation.categoryColor,
            seed: line.categoryName,
          ),
          title: Text(line.categoryName),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: line.ratio,
                minHeight: 6,
                color: barColor,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                line.spent.format(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: over ? theme.colorScheme.error : null,
                ),
              ),
              Text(
                'of ${line.allocated.format()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
