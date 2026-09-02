import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/haptics.dart';
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

/// Amount-first entry sheet.
///
/// Recording a transaction is the most frequent thing anyone does in this app,
/// so the amount gets a dedicated keypad rather than a text field behind the
/// OS keyboard, the category is a one-tap chip rather than a dropdown, and the
/// date defaults to today with shortcuts for the common cases. A typical entry
/// is three taps: digits, category, save.
class _TransactionFormSheet extends ConsumerStatefulWidget {
  const _TransactionFormSheet({required this.kind, this.existing});

  final TransactionKind kind;
  final Transaction? existing;

  @override
  ConsumerState<_TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<_TransactionFormSheet> {
  /// Entry is in minor units, the way an ATM or card terminal works: digits
  /// push in from the right, so there is no decimal point to get wrong.
  late int _minorUnits = widget.existing?.amount.minorUnits ?? 0;

  late final TextEditingController _noteController = TextEditingController(
    text: widget.existing?.note ?? '',
  );

  late DateTime _date = widget.existing?.occurredOn ?? DateTime.now();
  late String? _categoryId = widget.existing?.categoryId;

  bool _showNote = false;

  @override
  void initState() {
    super.initState();
    _showNote = (widget.existing?.note ?? '').isNotEmpty;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isValid => _minorUnits > 0;

  void _tapDigit(int digit) {
    // Cap at 9,999,999.99 so a stuck finger cannot overflow the display.
    if (_minorUnits > 99999999) return;
    Haptics.selection();
    setState(() => _minorUnits = _minorUnits * 10 + digit);
  }

  void _backspace() {
    if (_minorUnits == 0) return;
    Haptics.selection();
    setState(() => _minorUnits ~/= 10);
  }

  void _clear() {
    if (_minorUnits == 0) return;
    Haptics.medium();
    setState(() => _minorUnits = 0);
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
    if (!_isValid) return;
    Haptics.light();
    Navigator.of(context).pop(
      TransactionFormResult(
        amount: Money(
          minorUnits: _minorUnits,
          currencyCode: ref.read(currencyCodeProvider),
        ),
        occurredOn: _date,
        categoryId: _categoryId,
        note: _noteController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;
    final currency = ref.watch(currencyCodeProvider);
    final categoriesAsync = ref.watch(categoryListProvider(widget.kind));
    final amount = Money(minorUnits: _minorUnits, currencyCode: currency);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${isEditing ? 'Edit' : 'Add'} ${widget.kind.label.toLowerCase()}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _AmountDisplay(amount: amount, kind: widget.kind),
            const SizedBox(height: 16),
            categoriesAsync.when(
              loading: () => const SizedBox(
                height: 44,
                child: Center(child: LinearProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (categories) => _CategoryChips(
                categories: categories,
                value: _categoryId,
                onChanged: (id) {
                  Haptics.selection();
                  setState(() => _categoryId = id);
                },
              ),
            ),
            const SizedBox(height: 12),
            _DateRow(
              date: _date,
              onChanged: (date) {
                Haptics.selection();
                setState(() => _date = date);
              },
              onPick: _pickDate,
            ),
            const SizedBox(height: 8),
            if (_showNote)
              TextField(
                controller: _noteController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  isDense: true,
                ),
                textCapitalization: TextCapitalization.sentences,
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showNote = true),
                  icon: const Icon(Icons.notes, size: 18),
                  label: const Text('Add note'),
                ),
              ),
            const SizedBox(height: 4),
            _Keypad(
              onDigit: _tapDigit,
              onBackspace: _backspace,
              onClear: _clear,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isValid ? _submit : null,
              child: Text(isEditing ? 'Save' : 'Add ${widget.kind.label.toLowerCase()}'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The running total, sized to be the unmistakable focus of the sheet.
class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amount, required this.kind});

  final Money amount;
  final TransactionKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = amount.isZero;

    return Semantics(
      label: 'Amount ${amount.format()}',
      liveRegion: true,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          amount.format(),
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: muted
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// One-tap category selection, scrolling horizontally instead of hiding the
/// options behind a dropdown.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Guard against a stale category id (e.g. one that was deleted).
    final safeValue = categories.any((c) => c.id == value) ? value : null;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: safeValue == category.id,
                avatar: CategoryAvatar.fromCategory(category, size: 24),
                label: Text(category.name),
                onSelected: (selected) =>
                    onChanged(selected ? category.id : null),
              ),
            ),
          ChoiceChip(
            selected: safeValue == null,
            label: const Text('Uncategorized'),
            onSelected: (_) => onChanged(null),
          ),
        ],
      ),
    );
  }
}

/// Today and Yesterday cover almost every entry; anything else opens a picker.
class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.date,
    required this.onChanged,
    required this.onPick,
  });

  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onPick;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isToday = _sameDay(date, today);
    final isYesterday = _sameDay(date, yesterday);

    return Row(
      children: [
        ChoiceChip(
          selected: isToday,
          label: const Text('Today'),
          onSelected: (_) => onChanged(today),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          selected: isYesterday,
          label: const Text('Yesterday'),
          onSelected: (_) => onChanged(yesterday),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(
                isToday || isYesterday
                    ? 'Pick date'
                    : DateFormat.yMMMd().format(date),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Numeric keypad. Digits enter from the right in minor units.
class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            children: [
              for (final digit in row)
                Expanded(
                  child: _KeypadButton(
                    label: '$digit',
                    onPressed: () => onDigit(digit),
                  ),
                ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: _KeypadButton(
                label: 'C',
                semanticLabel: 'Clear amount',
                onPressed: onClear,
              ),
            ),
            Expanded(
              child: _KeypadButton(label: '0', onPressed: () => onDigit(0)),
            ),
            Expanded(
              child: _KeypadButton(
                icon: Icons.backspace_outlined,
                semanticLabel: 'Delete last digit',
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    this.label,
    this.icon,
    this.semanticLabel,
    required this.onPressed,
  }) : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          // Comfortably above the 48dp minimum touch target.
          height: 56,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 24)
                : Text(
                    label!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
