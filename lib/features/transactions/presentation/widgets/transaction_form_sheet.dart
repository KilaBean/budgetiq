import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/transaction.dart';

/// Values captured by the transaction form.
class TransactionFormResult {
  const TransactionFormResult({
    required this.amount,
    required this.occurredOn,
    this.categoryId,
    this.note,
  });

  final Money amount;
  final DateTime occurredOn;
  final String? categoryId;
  final String? note;
}

Future<TransactionFormResult?> showTransactionFormSheet(
  BuildContext context, {
  required TransactionKind kind,
  Transaction? existing,
}) {
  return showModalBottomSheet<TransactionFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _TransactionFormSheet(kind: kind, existing: existing),
  );
}

class _TransactionFormSheet extends ConsumerStatefulWidget {
  const _TransactionFormSheet({required this.kind, this.existing});

  final TransactionKind kind;
  final Transaction? existing;

  @override
  ConsumerState<_TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<_TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController(
    text: widget.existing != null
        ? widget.existing!.amount.major.toStringAsFixed(2)
        : '',
  );
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );

  late DateTime _date = widget.existing?.occurredOn ?? DateTime.now();
  late String? _categoryId = widget.existing?.categoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = Money.fromMajor(
      double.parse(_amountController.text),
      currencyCode: ref.read(currencyCodeProvider),
    );
    Navigator.of(context).pop(
      TransactionFormResult(
        amount: amount,
        occurredOn: _date,
        categoryId: _categoryId,
        note: _noteController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final categoriesAsync = ref.watch(categoryListProvider(widget.kind));

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
              '${isEditing ? 'Edit' : 'Add'} ${widget.kind.label.toLowerCase()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              validator: (v) {
                final value = double.tryParse(v ?? '');
                if (value == null) return 'Enter a valid amount.';
                if (value <= 0) return 'Amount must be greater than zero.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) => _CategoryDropdown(
                categories: categories,
                value: _categoryId,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              trailing: Text(DateFormat.yMMMd().format(_date)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Guard against a stale category id (e.g. deleted) not in the list.
    final safeValue = categories.any((c) => c.id == value) ? value : null;
    return DropdownButtonFormField<String?>(
      initialValue: safeValue,
      decoration: const InputDecoration(labelText: 'Category'),
      items: [
        const DropdownMenuItem(value: null, child: Text('Uncategorized')),
        ...categories.map(
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
        ),
      ],
      onChanged: onChanged,
    );
  }
}
