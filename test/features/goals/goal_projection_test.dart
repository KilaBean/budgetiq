import 'package:budgetiq/features/goals/domain/entities/goal.dart';
import 'package:budgetiq/features/goals/domain/services/goal_projection.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

Goal _goal({
  required double target,
  DateTime? targetDate,
  List<GoalContribution> contributions = const [],
}) {
  return Goal(
    id: 'g1',
    name: 'Fund',
    targetAmount: Money.fromMajor(target),
    currencyCode: 'USD',
    targetDate: targetDate,
    contributions: contributions,
  );
}

GoalContribution _c(double amount, DateTime on) => GoalContribution(
  id: '${on.millisecondsSinceEpoch}',
  amount: Money.fromMajor(amount),
  occurredOn: on,
);

void main() {
  test('no contributions: no ETA, full remaining', () {
    final p = projectGoal(_goal(target: 1000), now: DateTime(2026, 6, 1));
    expect(p.isMet, isFalse);
    expect(p.monthsToTarget, isNull);
    expect(p.remaining, Money.fromMajor(1000));
    expect(p.progressRatio, 0);
  });

  test('met goal reports 100% and zero months', () {
    final p = projectGoal(
      _goal(target: 500, contributions: [_c(500, DateTime(2026, 5, 1))]),
      now: DateTime(2026, 6, 1),
    );
    expect(p.isMet, isTrue);
    expect(p.progressRatio, 1);
    expect(p.monthsToTarget, 0);
    expect(p.remaining.isZero, isTrue);
  });

  test('steady pace extrapolates ETA deterministically', () {
    // 200 saved over 2 months (Apr, May) → 100/mo. 800 remaining → 8 months.
    final p = projectGoal(
      _goal(
        target: 1000,
        contributions: [
          _c(100, DateTime(2026, 4, 10)),
          _c(100, DateTime(2026, 5, 10)),
        ],
      ),
      now: DateTime(2026, 5, 20),
    );
    expect(p.contributed, Money.fromMajor(200));
    expect(p.remaining, Money.fromMajor(800));
    expect(p.monthsToTarget, 8);
  });

  test('deadline: computes required monthly and on-track flag', () {
    // 100 saved in June (100/mo pace). 900 remaining, deadline 3 months out.
    final p = projectGoal(
      _goal(
        target: 1000,
        targetDate: DateTime(2026, 9, 1),
        contributions: [_c(100, DateTime(2026, 6, 5))],
      ),
      now: DateTime(2026, 6, 15),
    );
    // remaining 900 / 3 months = 300/mo required.
    expect(p.requiredMonthly, Money.fromMajor(300));
    // pace ~100/mo → 9 months > 3 → behind.
    expect(p.onTrackForDeadline, isFalse);
  });

  test('passed deadline, unmet: marked not on track', () {
    final p = projectGoal(
      _goal(
        target: 1000,
        targetDate: DateTime(2026, 1, 1),
        contributions: [_c(100, DateTime(2025, 12, 1))],
      ),
      now: DateTime(2026, 6, 1),
    );
    expect(p.onTrackForDeadline, isFalse);
    expect(p.requiredMonthly, isNull);
  });
}
