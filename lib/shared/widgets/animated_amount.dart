import 'package:flutter/material.dart';

import '../domain/money.dart';

/// A money value that animates (counts up/down) when it changes — used for
/// headline figures so the dashboard feels alive.
class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.compact = false,
    this.duration = const Duration(milliseconds: 650),
  });

  final Money amount;
  final TextStyle? style;
  final bool compact;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // Key on currency so a currency switch resets cleanly.
      key: ValueKey(amount.currencyCode),
      tween: Tween(begin: 0, end: amount.major),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final shown = Money.fromMajor(value, currencyCode: amount.currencyCode);
        // Scale down rather than wrap/overflow when the number is long.
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            compact ? shown.formatCompact() : shown.format(),
            maxLines: 1,
            softWrap: false,
            style: style,
          ),
        );
      },
    );
  }
}
