import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/insight.dart';

/// Renders a single [Insight] as a leading-icon list tile, color-coded by
/// severity.
class InsightTile extends StatelessWidget {
  const InsightTile({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final financial = theme.extension<FinancialColors>()!;

    final (color, icon) = switch (insight.severity) {
      InsightSeverity.positive => (financial.income, Icons.check_circle),
      InsightSeverity.negative => (financial.expense, Icons.error),
      InsightSeverity.warning => (financial.warning, Icons.warning_amber),
      InsightSeverity.neutral => (theme.colorScheme.primary, Icons.insights),
    };

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        foregroundColor: color,
        child: Icon(icon),
      ),
      title: Text(
        insight.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(insight.message),
      isThreeLine: insight.message.length > 48,
    );
  }
}
