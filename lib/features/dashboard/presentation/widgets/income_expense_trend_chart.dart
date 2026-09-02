import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/services/monthly_trend.dart';

/// Grouped bar chart of income vs expense over the trend window.
class IncomeExpenseTrendChart extends StatelessWidget {
  const IncomeExpenseTrendChart({super.key, required this.series});

  final List<MonthlyTotals> series;

  /// Reads the series out as text for screen readers.
  String _spoken() => series
      .map(
        (m) =>
            '${DateFormat.MMMM().format(m.month.start)}: income '
            '${m.income.format()}, expenses ${m.expense.format()}',
      )
      .join('. ');

  @override
  Widget build(BuildContext context) {
    final financial = Theme.of(context).extension<FinancialColors>()!;
    final theme = Theme.of(context);

    // Format tooltips in the user's currency rather than the default USD.
    final currency = series.isEmpty ? 'USD' : series.first.income.currencyCode;
    final tooltipFormat = NumberFormat.compactSimpleCurrency(name: currency);

    final maxValue = series.fold<double>(1, (max, m) {
      final localMax = m.income.major > m.expense.major
          ? m.income.major
          : m.expense.major;
      return localMax > max ? localMax : max;
    });

    return Semantics(
      label: 'Income versus expenses by month. ${_spoken()}',
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxValue * 1.2,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                  tooltipFormat.format(rod.toY),
                  TextStyle(
                    color: theme.colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= series.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        DateFormat.MMM().format(series[i].month.start),
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < series.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: series[i].income.major,
                      color: financial.income,
                      width: 7,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    BarChartRodData(
                      toY: series[i].expense.major,
                      color: financial.expense,
                      width: 7,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
