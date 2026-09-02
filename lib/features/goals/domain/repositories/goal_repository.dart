import '../../../../shared/domain/money.dart';
import '../entities/goal.dart';

/// Contract for goals and their contributions. Implementations throw a
/// [Failure](../../../../core/error/failure.dart) on error.
abstract interface class GoalRepository {
  /// Active goals (with their contributions), newest first, falling back to
  /// cache when offline.
  Future<List<Goal>> getGoals();

  Future<Goal> createGoal({
    required String name,
    required Money targetAmount,
    DateTime? targetDate,
  });

  Future<void> deleteGoal(Goal goal);

  /// Adds a contribution to [goalId].
  Future<void> addContribution({
    required String goalId,
    required Money amount,
    required DateTime occurredOn,
    String? note,
  });

  Future<void> deleteContribution(String contributionId);
}
