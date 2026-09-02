import 'package:equatable/equatable.dart';

/// One weighted contributor to the overall financial health score.
class HealthFactor extends Equatable {
  const HealthFactor({
    required this.name,
    required this.score,
    required this.weight,
    required this.explanation,
  });

  final String name;

  /// Normalized factor score in [0, 1].
  final double score;

  /// Relative weight among applicable factors.
  final double weight;

  /// Plain-language reason for this factor's score.
  final String explanation;

  @override
  List<Object?> get props => [name, score, weight, explanation];
}

/// Overall 0–100 financial health score with its explainable breakdown.
class HealthScore extends Equatable {
  const HealthScore({required this.score, required this.factors});

  /// 0–100, rounded.
  final int score;
  final List<HealthFactor> factors;

  /// Coarse label for display.
  String get band {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs attention';
  }

  @override
  List<Object?> get props => [score, factors];
}
