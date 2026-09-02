import 'package:flutter/material.dart';

import '../../domain/entities/health_score.dart';

/// Card showing the overall financial health score, its band, and the
/// per-factor breakdown that explains it.
class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({
    super.key,
    required this.health,
    this.showFactors = true,
  });

  final HealthScore health;
  final bool showFactors;

  Color _bandColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (health.score >= 60) return scheme.primary;
    if (health.score >= 40) return scheme.tertiary;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _bandColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              label:
                  'Financial health score ${health.score} out of 100, '
                  '${health.band}',
              excludeSemantics: true,
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: health.score / 100,
                            strokeWidth: 6,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: color,
                          ),
                        ),
                        Text(
                          '${health.score}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial health',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        health.band,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showFactors && health.factors.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...health.factors.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Semantics(
                    container: true,
                    label:
                        '${f.name}: ${(f.score * 100).round()} out of 100. '
                        '${f.explanation}',
                    excludeSemantics: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(f.name, style: theme.textTheme.bodyMedium),
                            Text(
                              '${(f.score * 100).round()}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: f.score,
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.explanation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
