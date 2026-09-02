import 'package:flutter/material.dart';

import '../../../../shared/utils/category_visual.dart';
import '../../../../shared/widgets/category_avatar.dart';
import '../../domain/entities/category.dart';

/// Result of the category form: name, icon key, and color hex.
class CategoryFormResult {
  const CategoryFormResult({required this.name, this.icon, this.color});
  final String name;
  final String? icon;
  final String? color;
}

/// Shows a modal bottom sheet to create or edit a category, with icon and
/// color pickers and a live preview. Returns the values, or `null` if cancelled.
Future<CategoryFormResult?> showCategoryFormSheet(
  BuildContext context, {
  Category? existing,
}) {
  return showModalBottomSheet<CategoryFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CategoryFormSheet(existing: existing),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({this.existing});
  final Category? existing;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );

  late String _icon = widget.existing?.icon ?? CategoryVisual.iconNames.first;
  late Color _color = CategoryVisual.colorFor(
    colorHex: widget.existing?.color,
    seed: widget.existing?.name ?? 'new',
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      CategoryFormResult(
        name: _nameController.text.trim(),
        icon: _icon,
        color: CategoryVisual.toHex(_color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CategoryAvatar(
                    iconName: _icon,
                    colorHex: CategoryVisual.toHex(_color),
                    seed: 'preview',
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit category' : 'New category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required.'
                    : null,
              ),
              const SizedBox(height: 16),
              _PickerLabel('Color'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in CategoryVisual.swatches)
                    _Swatch(
                      color: c,
                      selected: c.toARGB32() == _color.toARGB32(),
                      onTap: () => setState(() => _color = c),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _PickerLabel('Icon'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final name in CategoryVisual.iconNames)
                    _IconChoice(
                      icon: CategoryVisual.iconFor(name),
                      color: _color,
                      selected: name == _icon,
                      onTap: () => setState(() => _icon = name),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                child: Text(isEditing ? 'Save' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerLabel extends StatelessWidget {
  const _PickerLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: color, width: 2) : null,
        ),
        child: Icon(
          icon,
          color: selected
              ? color
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
