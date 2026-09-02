import '../../domain/services/goal_projection.dart';

/// Turns a [GoalProjection] into a short, explainable status line.
String goalProjectionMessage(GoalProjection p) {
  if (p.isMet) return 'Goal reached! 🎉';

  final eta = p.monthsToTarget;
  final deadlineNote = switch (p.onTrackForDeadline) {
    true => ' — on track for your deadline',
    false => ' — behind your deadline',
    null => '',
  };

  if (eta == null) {
    if (p.requiredMonthly != null) {
      return 'Save ${p.requiredMonthly!.format()}/mo to hit your deadline.';
    }
    return 'Add contributions to project your finish date.';
  }

  if (eta <= 0) return 'On pace to finish this month$deadlineNote.';
  if (eta == 1) return 'About 1 month to go at your current pace$deadlineNote.';
  return 'About $eta months to go at your current pace$deadlineNote.';
}
