import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/haptics.dart';
import '../../domain/services/dashboard_summary.dart';

/// Donut chart of expense spend by category, with a legend.
///
/// Touching a slice lifts it and names it in the middle of the ring, so the
/// chart answers "what is that sliver?" without a legend hunt.
class CategoryBreakdownChart extends StatefulWidget {
  const CategoryBreakdownChart({super.key, required this.categories});

  final List<CategorySpend> categories;

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int? _touchedIndex;

  List<CategorySpend> get categories => widget.categories;

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

  /// Reads the slices out as text, e.g. "Food and Dining, 45 percent, $320.00".
  String _spokenBreakdown() => categories
      .map(
        (c) =>
            '${c.categoryName}, ${(c.fraction * 100).round()} percent, '
            '${c.amount.format()}',
      )
      .join('. ');

  /// Highlights the slice under the finger, with a tick of haptic feedback on
  /// each change so the chart feels physical rather than decorative.
  void _onTouch(FlTouchEvent event, PieTouchResponse? response) {
    final section = response?.touchedSection;
    final index = event.isInterestedForInteractions && section != null
        ? section.touchedSectionIndex
        : null;
    if (index == _touchedIndex) return;
    if (index != null) Haptics.selection();
    setState(() => _touchedIndex = index);
  }

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
          hint: 'Touch a slice to see its category and amount',
          excludeSemantics: true,
          child: SizedBox(
            height: 160,
            width: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 44,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(touchCallback: _onTouch),
                    sections: [
                      for (var i = 0; i < categories.length; i++)
                        PieChartSectionData(
                          value: categories[i].amount.major,
                          color: palette[i % palette.length],
                          // The ring shows proportion; the legend beside it
                          // carries the numbers, where they always have room.
                          showTitle: false,
                          // The touched slice lifts out of the ring.
                          radius: _touchedIndex == i ? 34 : 28,
                        ),
                    ],
                  ),
                ),
                if (_touchedIndex != null && _touchedIndex! < categories.length)
                  _CenterCallout(spend: categories[_touchedIndex!]),
              ],
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
                              '${categories[i].amount.format()}  ·  '
                              '${(categories[i].fraction * 100).round()}%',
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

/// Names the slice being touched, in the hole of the donut.
class _CenterCallout extends StatelessWidget {
  const _CenterCallout({required this.spend});

  final CategorySpend spend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 78,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spend.categoryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            spend.amount.formatCompact(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
