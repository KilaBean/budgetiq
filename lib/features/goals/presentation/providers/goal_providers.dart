import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/domain/money.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../data/datasources/goal_local_data_source.dart';
import '../../data/datasources/goal_remote_data_source.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';

part 'goal_providers.g.dart';

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) {
  return GoalRepositoryImpl(
    remote: GoalRemoteDataSource(ref.watch(supabaseClientProvider)),
    local: GoalLocalDataSource(ref.watch(jsonListCacheProvider)),
    queue: ref.watch(syncQueueProvider),
    isOnline: () => ref.read(isOnlineProvider),
    currentUserId: () => ref.read(supabaseClientProvider).auth.currentUser?.id,
    currencyCode: ref.watch(currencyCodeProvider),
    onEnqueued: () =>
        ref.read(syncControllerProvider.notifier).notifyEnqueued(),
  );
}

/// Loads and manages the user's goals.
@riverpod
class GoalList extends _$GoalList {
  @override
  Future<List<Goal>> build() => ref.watch(goalRepositoryProvider).getGoals();

  Future<void> create({
    required String name,
    required Money targetAmount,
    DateTime? targetDate,
  }) async {
    await ref
        .read(goalRepositoryProvider)
        .createGoal(
          name: name,
          targetAmount: targetAmount,
          targetDate: targetDate,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> remove(Goal goal) async {
    await ref.read(goalRepositoryProvider).deleteGoal(goal);
    ref.invalidateSelf();
    await future;
  }

  Future<void> addContribution({
    required String goalId,
    required Money amount,
    required DateTime occurredOn,
    String? note,
  }) async {
    await ref
        .read(goalRepositoryProvider)
        .addContribution(
          goalId: goalId,
          amount: amount,
          occurredOn: occurredOn,
          note: note,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> removeContribution(String contributionId) async {
    await ref.read(goalRepositoryProvider).deleteContribution(contributionId);
    ref.invalidateSelf();
    await future;
  }
}

/// Convenience selector for a single goal from the loaded list.
@riverpod
Goal? goalById(Ref ref, String goalId) {
  final goals = ref.watch(goalListProvider).value;
  if (goals == null) return null;
  for (final goal in goals) {
    if (goal.id == goalId) return goal;
  }
  return null;
}
