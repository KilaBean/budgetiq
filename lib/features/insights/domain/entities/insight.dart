import 'package:equatable/equatable.dart';

/// How an insight should be visually weighted / what it signals.
enum InsightSeverity { positive, neutral, warning, negative }

/// Category of insight, useful for icons, ordering and testing.
enum InsightType {
  spendingChange,
  spendingTrend,
  budgetOverspend,
  savingsRate,
  goalProgress,
}

/// A single rule-based, explainable financial insight.
///
/// Insights are generated deterministically from the user's data — never AI —
/// so each one can be traced to the rule and inputs that produced it.
class Insight extends Equatable {
  const Insight({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
  });

  final InsightType type;
  final InsightSeverity severity;
  final String title;
  final String message;

  @override
  List<Object?> get props => [type, severity, title, message];
}
