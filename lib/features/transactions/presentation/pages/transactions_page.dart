import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/haptics.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/domain/month.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../data/repositories/transaction_repository_impl.dart'
    show kTransactionWindowMonths;
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_form_sheet.dart';

/// The Activity tab: income and expenses in one place, switched with a
/// segmented control rather than costing two slots in the navigation bar.
///
/// [initialKind] preselects a side, which the legacy `/income` and `/expenses`
/// routes use so existing links land where the user expects.
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key, this.initialKind});

  final TransactionKind? initialKind;

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  late TransactionKind kind =
      widget.initialKind ?? TransactionKind.expense;

  void _setKind(TransactionKind next) {
    if (next == kind) return;
    Haptics.selection();
    setState(() => kind = next);
  }

  Color _accent(BuildContext context) {
    final financial = Theme.of(context).extension<FinancialColors>()!;
    return kind == TransactionKind.income
        ? financial.income
        : financial.expense;
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    Transaction? existing,
  }) async {
    final result = await showTransactionFormSheet(
      context,
      kind: kind,
      existing: existing,
    );
    if (result == null) return;
    Haptics.light();
    final notifier = ref.read(transactionListProvider(kind).notifier);
    try {
      if (existing == null) {
        await notifier.create(
          amount: result.amount,
          occurredOn: result.occurredOn,
          categoryId: result.categoryId,
          note: result.note,
        );
      } else {
        await notifier.edit(
          original: existing,
          amount: result.amount,
          occurredOn: result.occurredOn,
          categoryId: result.categoryId,
          note: result.note,
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    Haptics.medium();
    final notifier = ref.read(transactionListProvider(kind).notifier);
    try {
      await notifier.delete(transaction);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${kind.label} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => notifier.create(
                amount: transaction.amount,
                occurredOn: transaction.occurredOn,
                categoryId: transaction.categoryId,
                note: transaction.note,
              ),
            ),
          ),
        );
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _loadOlder(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(transactionListProvider(kind).notifier).loadOlder();
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  void _showError(BuildContext context, Object error) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(messageFromError(error))));
  }

  Future<void> _openFilterSheet(BuildContext context, WidgetRef ref) async {
    final categories = ref.read(categoryListProvider(kind)).value ?? const [];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FilterSheet(kind: kind, categories: categories),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionListProvider(kind));
    final filtered = ref.watch(filteredTransactionsProvider(kind));
    final filter = ref.watch(transactionFilterControllerProvider(kind));
    final monthTotal = ref.watch(currentMonthTotalProvider(kind));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: Icon(
              filter.isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter',
            onPressed: () => _openFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categories',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CategoriesPage(kind: kind),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_tx_${kind.name}',
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: Text('Add ${kind.label.toLowerCase()}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SegmentedButton<TransactionKind>(
              segments: const [
                ButtonSegment(
                  value: TransactionKind.expense,
                  icon: Icon(Icons.trending_down, size: 18),
                  label: Text('Expenses'),
                ),
                ButtonSegment(
                  value: TransactionKind.income,
                  icon: Icon(Icons.trending_up, size: 18),
                  label: Text('Income'),
                ),
              ],
              selected: {kind},
              onSelectionChanged: (selection) => _setKind(selection.first),
              showSelectedIcon: false,
            ),
          ),
          _MonthSummaryHeader(
            label: filter.isActive
                ? 'Filtered ${kind.label.toLowerCase()}'
                : '${Month.current().label} ${kind.label.toLowerCase()}',
            amount: monthTotal?.format(),
            accent: _accent(context),
          ),
          if (filter.isActive)
            _ActiveFilterChips(
              kind: kind,
              onClear: () => ref
                  .read(transactionFilterControllerProvider(kind).notifier)
                  .clear(),
            ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const SkeletonList(),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(transactionListProvider(kind)),
              ),
              data: (page) {
                final transactions = filtered ?? const [];
                if (transactions.isEmpty) {
                  // History older than the opening window may still exist —
                  // don't dead-end the user on an empty window.
                  if (page.hasMore && !filter.isActive) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: EmptyState(
                            icon: kind == TransactionKind.income
                                ? Icons.trending_up
                                : Icons.trending_down,
                            title:
                                'Nothing in the last '
                                '$kTransactionWindowMonths months',
                            message: 'Your older history is still there.',
                            actionLabel: 'Add ${kind.label.toLowerCase()}',
                            onAction: () => _openForm(context, ref),
                          ),
                        ),
                        _LoadOlderButton(
                          isLoading: page.isLoadingMore,
                          onPressed: () => _loadOlder(context, ref),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                  return EmptyState(
                    icon: kind == TransactionKind.income
                        ? Icons.trending_up
                        : Icons.trending_down,
                    title: filter.isActive
                        ? 'No results'
                        : 'No ${kind.label.toLowerCase()} yet',
                    message: filter.isActive
                        ? 'Try adjusting your filters.'
                        : 'Tap "Add ${kind.label.toLowerCase()}" to record your first entry.',
                    actionLabel: filter.isActive
                        ? 'Clear filters'
                        : 'Add ${kind.label.toLowerCase()}',
                    onAction: filter.isActive
                        ? () => ref
                              .read(
                                transactionFilterControllerProvider(
                                  kind,
                                ).notifier,
                              )
                              .clear()
                        : () => _openForm(context, ref),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(transactionListProvider(kind)),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < transactions.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  indent: 72,
                                  endIndent: 0,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: 0.4),
                                ),
                              _TransactionTile(
                                transaction: transactions[i],
                                accent: _accent(context),
                                onTap: () => _openForm(
                                  context,
                                  ref,
                                  existing: transactions[i],
                                ),
                                onDelete: () =>
                                    _delete(context, ref, transactions[i]),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (page.hasMore)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _LoadOlderButton(
                            isLoading: page.isLoadingMore,
                            onPressed: () => _loadOlder(context, ref),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet
// ---------------------------------------------------------------------------

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet({required this.kind, required this.categories});

  final TransactionKind kind;
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterControllerProvider(kind));
    final controller = ref.read(
      transactionFilterControllerProvider(kind).notifier,
    );
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Filter', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (filter.isActive)
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Date range', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                filter.dateRange != null
                    ? '${DateFormat.yMMMd().format(filter.dateRange!.start)} – '
                          '${DateFormat.yMMMd().format(filter.dateRange!.end)}'
                    : 'Select date range',
              ),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                  initialDateRange: filter.dateRange,
                );
                if (range != null) controller.setDateRange(range);
              },
            ),
            if (filter.dateRange != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => controller.setDateRange(null),
                  child: const Text('Clear date'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (categories.isNotEmpty) ...[
              Text('Category', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final cat in categories)
                      CheckboxListTile(
                        dense: true,
                        title: Text(cat.name),
                        secondary: CategoryAvatar.fromCategory(cat, size: 28),
                        value: filter.categoryIds.contains(cat.id),
                        onChanged: (_) => controller.toggleCategory(cat.id),
                      ),
                  ],
                ),
              ),
            ] else
              const Expanded(child: SizedBox.shrink()),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Active filter chips row
// ---------------------------------------------------------------------------

class _ActiveFilterChips extends ConsumerWidget {
  const _ActiveFilterChips({required this.kind, required this.onClear});

  final TransactionKind kind;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(transactionFilterControllerProvider(kind));
    final controller = ref.read(
      transactionFilterControllerProvider(kind).notifier,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          if (filter.dateRange != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${DateFormat.MMMd().format(filter.dateRange!.start)} – '
                  '${DateFormat.MMMd().format(filter.dateRange!.end)}',
                ),
                onSelected: (_) {},
                onDeleted: () => controller.setDateRange(null),
                selected: true,
              ),
            ),
          if (filter.categoryIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  '${filter.categoryIds.length} '
                  '${filter.categoryIds.length == 1 ? 'category' : 'categories'}',
                ),
                onSelected: (_) {},
                onDeleted: () {
                  final range = filter.dateRange;
                  controller.clear();
                  if (range != null) controller.setDateRange(range);
                },
                selected: true,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared private widgets
// ---------------------------------------------------------------------------

class _MonthSummaryHeader extends StatelessWidget {
  const _MonthSummaryHeader({
    required this.label,
    required this.amount,
    required this.accent,
  });

  final String label;
  final String? amount;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            amount ?? '—',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.accent,
    required this.onTap,
    required this.onDelete,
  });

  final Transaction transaction;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sign = transaction.kind == TransactionKind.income ? '+' : '-';
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
        onTap: onTap,
        leading: CategoryAvatar(
          iconName: transaction.categoryIcon,
          colorHex: transaction.categoryColor,
          seed: transaction.categoryName ?? 'Uncategorized',
        ),
        title: Text(transaction.categoryName ?? 'Uncategorized'),
        subtitle: Text(
          [
            DateFormat.yMMMd().format(transaction.occurredOn),
            if (transaction.note?.isNotEmpty ?? false) transaction.note!,
          ].join(' · '),
        ),
        trailing: Text(
          '$sign${transaction.amount.format()}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
      ),
    );
  }
}

/// Pulls in the next page of history below the opening window.
class _LoadOlderButton extends StatelessWidget {
  const _LoadOlderButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.history),
        label: Text(isLoading ? 'Loading…' : 'Load older transactions'),
      ),
    );
  }
}
