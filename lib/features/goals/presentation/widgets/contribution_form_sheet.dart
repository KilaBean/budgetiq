import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/domain/money.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class ContributionFormResult {
  const ContributionFormResult({
    required this.amount,
    required this.occurredOn,
    this.note,
  });
  final Money amount;
  final DateTime occurredOn;
  final String? note;
}

Future<ContributionFormResult?> showContributionFormSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ContributionFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ContributionFormSheet(),
  );
}

class _ContributionFormSheet extends ConsumerStatefulWidget {
  const _ContributionFormSheet();

  @override
  ConsumerState<_ContributionFormSheet> createState() =>
      _ContributionFormSheetState();
}

class _ContributionFormSheetState
    extends ConsumerState<_ContributionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();

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
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ContributionFormResult(
        amount: Money.fromMajor(
          double.parse(_amountController.text),
          currencyCode: ref.read(currencyCodeProvider),
        ),
        occurredOn: _date,
        note: _noteController.text,
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
            Text(
              'Add contribution',
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
            const SizedBox(height: 8),
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
            FilledButton(onPressed: _submit, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
