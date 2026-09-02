import 'package:flutter/material.dart';

/// A small strength meter for the sign-up password field.
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  /// 0 = none, 1 = weak, 2 = fair, 3 = strong.
  int get _score {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (password.isEmpty) return const SizedBox.shrink();

    final score = _score;
    final (label, color) = switch (score) {
      <= 1 => ('Weak', theme.colorScheme.error),
      2 => ('Fair', Colors.orange),
      _ => ('Strong', Colors.green),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          for (var i = 1; i <= 3; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= score
                      ? color
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 6),
          ],
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
