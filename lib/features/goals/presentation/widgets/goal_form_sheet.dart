import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/domain/money.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class GoalFormResult {
  const GoalFormResult({
    required this.name,
    required this.targetAmount,
    this.targetDate,
  });
  final String name;
  final Money targetAmount;
  final DateTime? targetDate;
}

Future<GoalFormResult?> showGoalFormSheet(BuildContext context) {
  return showModalBottomSheet<GoalFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _GoalFormSheet(),
  );
}

class _GoalFormSheet extends ConsumerStatefulWidget {
  const _GoalFormSheet();

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime(now.year, now.month + 6, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      GoalFormResult(
        name: _nameController.text.trim(),
        targetAmount: Money.fromMajor(
          double.parse(_amountController.text),
          currencyCode: ref.read(currencyCodeProvider),
        ),
        targetDate: _targetDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text('New goal', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Emergency fund',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Target amount',
                prefixText: '\$ ',
              ),
              validator: (v) {
                final value = double.tryParse(v ?? '');
                if (value == null) return 'Enter a valid amount.';
                if (value <= 0) return 'Target must be greater than zero.';
                return null;
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Target date (optional)'),
              trailing: Text(
                _targetDate == null
                    ? 'None'
                    : DateFormat.yMMMd().format(_targetDate!),
              ),
              onTap: _pickDate,
            ),
            if (_targetDate != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _targetDate = null),
                  child: const Text('Clear date'),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Create goal')),
          ],
        ),
      ),
    );
  }
}
