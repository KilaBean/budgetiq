import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class AllocationFormResult {
  const AllocationFormResult({
    required this.expenseCategoryId,
    required this.amount,
  });
  final String expenseCategoryId;
  final Money amount;
}

/// Sheet to set a category's monthly allocation. When [fixedCategoryId] is
/// provided the category is locked (editing an existing line).
Future<AllocationFormResult?> showAllocationFormSheet(
  BuildContext context, {
  String? fixedCategoryId,
  double? initialAmount,
}) {
  return showModalBottomSheet<AllocationFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AllocationFormSheet(
      fixedCategoryId: fixedCategoryId,
      initialAmount: initialAmount,
    ),
  );
}

class _AllocationFormSheet extends ConsumerStatefulWidget {
  const _AllocationFormSheet({this.fixedCategoryId, this.initialAmount});

  final String? fixedCategoryId;
  final double? initialAmount;

  @override
  ConsumerState<_AllocationFormSheet> createState() =>
      _AllocationFormSheetState();
}

class _AllocationFormSheetState extends ConsumerState<_AllocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController(
    text: widget.initialAmount?.toStringAsFixed(2) ?? '',
  );
  late String? _categoryId = widget.fixedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) return;
    Navigator.of(context).pop(
      AllocationFormResult(
        expenseCategoryId: _categoryId!,
        amount: Money.fromMajor(
          double.parse(_amountController.text),
          currencyCode: ref.read(currencyCodeProvider),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.fixedCategoryId != null;
    final categoriesAsync = ref.watch(
      categoryListProvider(TransactionKind.expense),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              locked ? 'Edit allocation' : 'Add allocation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (!locked)
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Could not load categories.'),
                data: (categories) => _CategoryPicker(
                  categories: categories,
                  value: _categoryId,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
              ),
            if (!locked) const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              autofocus: locked,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Monthly amount',
                prefixText: '\$ ',
              ),
              validator: (v) {
                final value = double.tryParse(v ?? '');
                if (value == null) return 'Enter a valid amount.';
                if (value < 0) return 'Amount cannot be negative.';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = categories.any((c) => c.id == value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      decoration: const InputDecoration(labelText: 'Expense category'),
      items: categories
          .map(
            (c) => DropdownMenuItem(
              value: c.id,
              child: Row(
                children: [
                  CategoryAvatar.fromCategory(c, size: 28),
                  const SizedBox(width: 10),
                  Text(c.name),
                ],
              ),
            ),
          )
          .toList(),
      validator: (v) => v == null ? 'Choose a category.' : null,
      onChanged: onChanged,
    );
  }
}
