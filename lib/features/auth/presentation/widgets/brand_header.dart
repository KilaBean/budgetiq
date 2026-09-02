import 'package:flutter/material.dart';

/// App brand mark for auth screens: a tinted rounded-square icon + wordmark.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.savings_rounded,
            color: theme.colorScheme.onPrimary,
            size: 34,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'BudgetIQ',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
