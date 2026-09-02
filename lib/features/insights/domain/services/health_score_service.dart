import 'dart:math' as math;

import '../../../../shared/domain/money.dart';
import '../../../budgets/domain/services/budget_progress.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/services/goal_projection.dart';
import '../entities/health_score.dart';

/// Target savings rate that earns full marks on the savings factor.
const double _targetSavingsRate = 0.20;

const double _wSavings = 0.35;
const double _wBudget = 0.25;
const double _wConsistency = 0.20;
const double _wGoals = 0.20;

/// Computes the 0–100 financial health score from its four factors. Each
/// factor is scored in [0, 1] with a plain-language explanation; only
/// applicable factors contribute, and their weights are renormalized so the
/// score is always out of 100. Fully deterministic and explainable.
HealthScore computeHealthScore({
  required double savingsRate,
  required bool hasIncome,
  BudgetSummary? budgetSummary,
  List<Money> monthlyExpenses = const [],
  List<Goal> goals = const [],
}) {
  final factors = <HealthFactor>[];

  // 1. Savings rate.
  if (hasIncome) {
    final score = (savingsRate / _targetSavingsRate).clamp(0.0, 1.0);
    factors.add(
      HealthFactor(
        name: 'Savings rate',
        score: score,
        weight: _wSavings,
        explanation:
            'You saved ${(savingsRate * 100).round()}% of income (target '
            '${(_targetSavingsRate * 100).round()}%).',
      ),
    );
  }

  // 2. Budget adherence.
  if (budgetSummary != null &&
      budgetSummary.lines.isNotEmpty &&
      !budgetSummary.totalAllocated.isZero) {
    final allocated = budgetSummary.totalAllocated.minorUnits;
    final spent = budgetSummary.totalSpent.minorUnits;
    final overspend = spent <= allocated
        ? 0.0
        : (spent - allocated) / allocated;
    final score = (1 - overspend).clamp(0.0, 1.0);
    factors.add(
      HealthFactor(
        name: 'Budget adherence',
        score: score,
        weight: _wBudget,
        explanation: spent <= allocated
            ? 'You stayed within your overall budget.'
            : 'You exceeded your budget by ${(overspend * 100).round()}%.',
      ),
    );
  }

  // 3. Spending consistency (lower month-to-month variation is better).
  final expenseValues = monthlyExpenses
      .map((m) => m.major)
      .where((v) => v > 0)
      .toList();
  if (expenseValues.length >= 2) {
    final mean = expenseValues.reduce((a, b) => a + b) / expenseValues.length;
    final variance =
        expenseValues
            .map((v) => math.pow(v - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        expenseValues.length;
    final cv = mean == 0 ? 0.0 : math.sqrt(variance) / mean;
    final score = (1 - cv).clamp(0.0, 1.0);
    factors.add(
      HealthFactor(
        name: 'Spending consistency',
        score: score,
        weight: _wConsistency,
        explanation: score >= 0.7
            ? 'Your monthly spending is steady and predictable.'
            : 'Your monthly spending varies quite a bit.',
      ),
    );
  }

  // 4. Goal completion (average progress across active goals).
  final activeGoals = goals
      .where((g) => g.status != GoalStatus.archived)
      .toList();
  if (activeGoals.isNotEmpty) {
    final avg =
        activeGoals
            .map((g) => projectGoal(g).progressRatio)
            .reduce((a, b) => a + b) /
        activeGoals.length;
    factors.add(
      HealthFactor(
        name: 'Goal progress',
        score: avg.clamp(0.0, 1.0),
        weight: _wGoals,
        explanation:
            'Average progress across your goals is ${(avg * 100).round()}%.',
      ),
    );
  }

  if (factors.isEmpty) {
    return const HealthScore(score: 0, factors: []);
  }

  final totalWeight = factors.fold<double>(0, (sum, f) => sum + f.weight);
  final weighted = factors.fold<double>(
    0,
    (sum, f) => sum + f.score * (f.weight / totalWeight),
  );

  return HealthScore(score: (weighted * 100).round(), factors: factors);
}
