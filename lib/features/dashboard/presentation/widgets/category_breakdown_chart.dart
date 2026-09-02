import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/services/dashboard_summary.dart';

/// Donut chart of expense spend by category, with a legend.
class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key, required this.categories});

  final List<CategorySpend> categories;

  /// Palette generated from the theme so colors stay consistent and readable.
  List<Color> _palette(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.tertiary,
      scheme.secondary,
      scheme.error,
      scheme.primaryContainer,
      scheme.outline,
    ];
  }

  /// Black or white text, whichever contrasts with [background] — keeps the
  /// on-slice percentage labels legible across the whole palette.
  Color _labelColor(Color background) =>
      background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  /// Reads the slices out as text, e.g. "Food and Dining, 45 percent, $320.00".
  String _spokenBreakdown() => categories
      .map(
        (c) =>
            '${c.categoryName}, ${(c.fraction * 100).round()} percent, '
            '${c.amount.format()}',
      )
      .join('. ');

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // The donut carries no text of its own, so it is described in full for
        // screen readers; the legend beside it is already readable.
        Semantics(
          label: 'Spending by category. ${_spokenBreakdown()}',
          image: true,
          excludeSemantics: true,
          child: SizedBox(
            height: 160,
            width: 160,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 44,
                sectionsSpace: 2,
                sections: [
                  for (var i = 0; i < categories.length; i++)
                    PieChartSectionData(
                      value: categories[i].amount.major,
                      color: palette[i % palette.length],
                      title: '${(categories[i].fraction * 100).round()}%',
                      radius: 28,
                      titleStyle: theme.textTheme.labelSmall?.copyWith(
                        color: _labelColor(palette[i % palette.length]),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < categories.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: palette[i % palette.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categories[i].categoryName,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              categories[i].amount.format(),
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
