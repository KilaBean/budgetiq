import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../entities/goal.dart';

/// Deterministic, explainable projection for a goal — no AI, pure arithmetic.
class GoalProjection {
  const GoalProjection({
    required this.contributed,
    required this.remaining,
    required this.progressRatio,
    required this.isMet,
    this.monthsToTarget,
    this.requiredMonthly,
    this.onTrackForDeadline,
  });

  final Money contributed;
  final Money remaining;

  /// Fraction complete, clamped to [0, 1].
  final double progressRatio;
  final bool isMet;

  /// Estimated months to reach the target at the average contribution rate.
  /// `null` when there is no contribution history to extrapolate from.
  final int? monthsToTarget;

  /// Monthly amount needed to hit an explicit [Goal.targetDate]. `null` when
  /// no deadline is set or it has passed.
  final Money? requiredMonthly;

  /// Whether the projected pace meets the deadline. `null` when not applicable.
  final bool? onTrackForDeadline;
}

/// Computes a [GoalProjection] for [goal] as of [now] (defaults to today).
///
/// Average pace is `contributed / monthsElapsed`, where monthsElapsed counts
/// from the first contribution's month through [now] (minimum 1). This keeps
/// the ETA fully explainable and unit-testable.
GoalProjection projectGoal(Goal goal, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final currency = goal.currencyCode;
  final contributed = goal.contributed;
  final target = goal.targetAmount;

  final remainingMinor = (target.minorUnits - contributed.minorUnits).clamp(
    0,
    target.minorUnits,
  );
  final remaining = Money(minorUnits: remainingMinor, currencyCode: currency);
  final progressRatio = target.isZero
      ? 0.0
      : (contributed.minorUnits / target.minorUnits).clamp(0.0, 1.0);
  final isMet = remainingMinor == 0;

  if (isMet) {
    return GoalProjection(
      contributed: contributed,
      remaining: remaining,
      progressRatio: 1,
      isMet: true,
      monthsToTarget: 0,
    );
  }

  // Average monthly pace from contribution history.
  int? monthsToTarget;
  if (goal.contributions.isNotEmpty) {
    final firstMonth = goal.contributions
        .map((c) => Month.fromDate(c.occurredOn))
        .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
    final monthsElapsed = firstMonth.monthsUntil(Month.fromDate(today)) + 1;
    final span = monthsElapsed < 1 ? 1 : monthsElapsed;
    final avgPaceMinor = contributed.minorUnits / span;
    if (avgPaceMinor > 0) {
      monthsToTarget = (remainingMinor / avgPaceMinor).ceil();
    }
  }

  // Deadline analysis.
  Money? requiredMonthly;
  bool? onTrackForDeadline;
  final deadline = goal.targetDate;
  if (deadline != null) {
    final monthsLeft = Month.fromDate(
      today,
    ).monthsUntil(Month.fromDate(deadline));
    if (monthsLeft > 0) {
      requiredMonthly = Money(
        minorUnits: (remainingMinor / monthsLeft).ceil(),
        currencyCode: currency,
      );
      onTrackForDeadline =
          monthsToTarget != null && monthsToTarget <= monthsLeft;
    } else {
      // Deadline now or past and not met.
      onTrackForDeadline = false;
    }
  }

  return GoalProjection(
    contributed: contributed,
    remaining: remaining,
    progressRatio: progressRatio,
    isMet: false,
    monthsToTarget: monthsToTarget,
    requiredMonthly: requiredMonthly,
    onTrackForDeadline: onTrackForDeadline,
  );
}
