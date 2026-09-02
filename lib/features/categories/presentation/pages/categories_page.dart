import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../domain/entities/category.dart';
import '../providers/category_providers.dart';
import '../widgets/category_form_sheet.dart';

/// Manage the categories for a given [kind] (income or expense).
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key, required this.kind});

  final TransactionKind kind;

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    Category? existing,
  }) async {
    final result = await showCategoryFormSheet(context, existing: existing);
    if (result == null) return;
    final notifier = ref.read(categoryListProvider(kind).notifier);
    try {
      if (existing == null) {
        await notifier.create(
          name: result.name,
          icon: result.icon,
          color: result.color,
        );
      } else {
        await notifier.edit(
          existing.copyWith(
            name: result.name,
            icon: result.icon,
            color: result.color,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, e);
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    try {
      await ref.read(categoryListProvider(kind).notifier).delete(category);
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
    final categoriesAsync = ref.watch(categoryListProvider(kind));

    return Scaffold(
      appBar: AppBar(title: Text('${kind.label} categories')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_categories',
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: categoriesAsync.when(
        loading: () => const SkeletonList(),
        error: (e, _) => ErrorView(
          error: e,
          onRetry: () => ref.invalidate(categoryListProvider(kind)),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories',
              message:
                  'Create a category to organize your ${kind.label.toLowerCase()}.',
              actionLabel: 'Add category',
              onAction: () => _openForm(context, ref),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final category = categories[i];
              return Dismissible(
                key: ValueKey(category.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete_outline),
                ),
                confirmDismiss: (_) async {
                  await _delete(context, ref, category);
                  return false; // list refreshes from source of truth
                },
                child: ListTile(
                  leading: CategoryAvatar.fromCategory(category),
                  title: Text(category.name),
                  subtitle: category.isSystem ? const Text('Default') : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit ${category.name}',
                    onPressed: () =>
                        _openForm(context, ref, existing: category),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
