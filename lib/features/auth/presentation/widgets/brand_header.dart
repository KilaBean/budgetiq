import 'package:flutter/material.dart';

/// App brand mark for auth screens: a tinted rounded-square icon + wordmark.
///
/// The mark scales up as the screen appears, picking up where the launch
/// artwork left off (see `SplashGate`) rather than snapping into place.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: reducedMotion ? 1 : 0.72, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
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
