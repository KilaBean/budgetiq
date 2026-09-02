import '../../budgets/domain/services/budget_progress.dart';
import '../../goals/domain/entities/goal.dart';
import '../../goals/domain/services/goal_projection.dart';

/// A notifiable financial event. [key] is stable per occurrence so each alert
/// fires at most once (deduped via the notification log).
class AlertEvent {
  const AlertEvent({
    required this.key,
    required this.title,
    required this.body,
  });

  final String key;
  final String title;
  final String body;
}

/// Threshold at which a "nearing budget" alert fires.
const double kNearBudgetThreshold = 0.8;

/// Derives the alert events implied by the current budget + goals. Pure and
/// deterministic so it can be unit-tested. [periodKey] scopes budget alerts to
/// the month so they can re-fire next month.
List<AlertEvent> buildAlertEvents({
  required String periodKey,
  BudgetSummary? budget,
  List<Goal> goals = const [],
}) {
  final events = <AlertEvent>[];

  if (budget != null) {
    for (final line in budget.lines) {
      final id = line.allocation.expenseCategoryId;
      if (line.isOverBudget) {
        events.add(
          AlertEvent(
            key: 'budget_over_${id}_$periodKey',
            title: 'Over budget',
            body:
                "You've gone over your ${line.categoryName} budget "
                '(${line.spent.format()} of ${line.allocated.format()}).',
          ),
        );
      } else if (line.ratio >= kNearBudgetThreshold) {
        events.add(
          AlertEvent(
            key: 'budget_near_${id}_$periodKey',
            title: 'Approaching budget limit',
            body:
                "You've used ${(line.ratio * 100).round()}% of your "
                '${line.categoryName} budget.',
          ),
        );
      }
    }
  }

  for (final goal in goals) {
    if (goal.status == GoalStatus.archived) continue;
    if (projectGoal(goal).isMet) {
      events.add(
        AlertEvent(
          key: 'goal_met_${goal.id}',
          title: 'Goal reached 🎉',
          body: "You've reached your ${goal.name} goal!",
        ),
      );
    }
  }

  return events;
}
