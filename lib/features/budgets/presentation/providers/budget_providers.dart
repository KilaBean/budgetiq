import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/domain/money.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../shared/domain/month.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../../dashboard/presentation/providers/selected_month_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/datasources/budget_local_data_source.dart';
import '../../data/datasources/budget_remote_data_source.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/services/budget_progress.dart';

part 'budget_providers.g.dart';

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(Ref ref) {
  final categoryCache = CategoryLocalDataSource(
    ref.watch(jsonListCacheProvider),
  );
  return BudgetRepositoryImpl(
    remote: BudgetRemoteDataSource(ref.watch(supabaseClientProvider)),
    local: BudgetLocalDataSource(ref.watch(jsonListCacheProvider)),
    queue: ref.watch(syncQueueProvider),
    isOnline: () => ref.read(isOnlineProvider),
    currencyCode: ref.watch(currencyCodeProvider),
    currentUserId: () => ref.read(supabaseClientProvider).auth.currentUser?.id,
    resolveCategoryName: (categoryId) {
      for (final row in categoryCache.read(TransactionKind.expense)) {
        if (row['id'] == categoryId) return row['name'] as String?;
      }
      return null;
    },
    onEnqueued: () =>
        ref.read(syncControllerProvider.notifier).notifyEnqueued(),
  );
}

/// The current month's budget (or `null` if none has been set up).
@riverpod
class CurrentBudget extends _$CurrentBudget {
  @override
  Future<Budget?> build() {
    return ref.watch(budgetRepositoryProvider).getBudget(Month.current());
  }

  Future<void> setAllocation({
    required String expenseCategoryId,
    required Money amount,
  }) async {
    await ref
        .read(budgetRepositoryProvider)
        .setAllocation(
          month: Month.current(),
          expenseCategoryId: expenseCategoryId,
          amount: amount,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> removeAllocation(BudgetAllocation allocation) async {
    await ref.read(budgetRepositoryProvider).removeAllocation(allocation);
    ref.invalidateSelf();
    await future;
  }
}

/// Spent-vs-allocated summary for the dashboard's selected month, combining the
/// budget with that month's expenses. `null` while either source is loading.
@riverpod
BudgetSummary? currentBudgetSummary(Ref ref) {
  final budget = ref.watch(currentBudgetProvider).value;
  final expenses = ref.watch(transactionItemsProvider(TransactionKind.expense));
  if (budget == null || expenses == null) return null;

  final month = ref.watch(selectedMonthProvider);
  final monthExpenses = expenses
      .where((t) => month.contains(t.occurredOn))
      .toList();
  return buildBudgetSummary(budget: budget, monthExpenses: monthExpenses);
}
