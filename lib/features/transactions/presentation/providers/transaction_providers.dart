import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../categories/data/datasources/category_local_data_source.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../data/datasources/transaction_local_data_source.dart';
import '../../data/datasources/transaction_remote_data_source.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_page.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/transaction_filter.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(Ref ref) {
  final categoryCache = CategoryLocalDataSource(
    ref.watch(jsonListCacheProvider),
  );
  return TransactionRepositoryImpl(
    remote: TransactionRemoteDataSource(ref.watch(supabaseClientProvider)),
    local: TransactionLocalDataSource(ref.watch(jsonListCacheProvider)),
    queue: ref.watch(syncQueueProvider),
    isOnline: () => ref.read(isOnlineProvider),
    currentUserId: () => ref.read(supabaseClientProvider).auth.currentUser?.id,
    resolveCategory: (kind, categoryId) {
      if (categoryId == null) return null;
      for (final row in categoryCache.read(kind)) {
        if (row['id'] == categoryId) {
          return {
            'name': row['name'],
            'icon': row['icon'],
            'color': row['color'],
          };
        }
      }
      return null;
    },
    currencyCode: ref.watch(currencyCodeProvider),
    onEnqueued: () =>
        ref.read(syncControllerProvider.notifier).notifyEnqueued(),
  );
}

/// Loads and manages transactions of a given [kind].
///
/// Holds the rolling window the app opens on; [loadOlder] appends pages of
/// older history on demand.
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<TransactionPage> build(TransactionKind kind) {
    return ref.watch(transactionRepositoryProvider).getTransactions(kind);
  }

  /// Appends the next page of older transactions. No-op when none remain or a
  /// page is already in flight.
  Future<void> loadOlder() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.items.isEmpty) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final older = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(kind, olderThan: current.items.last.occurredOn);
      state = AsyncData(
        TransactionPage(
          items: [...current.items, ...older.items],
          hasMore: older.hasMore,
        ),
      );
    } catch (_) {
      // Keep what is already loaded; the button simply becomes tappable again.
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  Future<void> create({
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .createTransaction(
          kind: kind,
          amount: amount,
          occurredOn: occurredOn,
          categoryId: categoryId,
          note: note,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> edit({
    required Transaction original,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  }) async {
    await ref
        .read(transactionRepositoryProvider)
        .updateTransaction(
          original: original,
          amount: amount,
          occurredOn: occurredOn,
          categoryId: categoryId,
          note: note,
        );
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(Transaction transaction) async {
    await ref
        .read(transactionRepositoryProvider)
        .deleteTransaction(transaction);
    ref.invalidateSelf();
    await future;
  }
}

/// Active filter for a transaction list. Scoped per [kind] so income and
/// expense tabs maintain independent filter state.
@riverpod
class TransactionFilterController extends _$TransactionFilterController {
  @override
  TransactionFilter build(TransactionKind kind) => const TransactionFilter();

  void setDateRange(DateTimeRange? range) =>
      state = state.copyWith(dateRange: range);

  void toggleCategory(String categoryId) {
    final ids = Set<String>.from(state.categoryIds);
    if (ids.contains(categoryId)) {
      ids.remove(categoryId);
    } else {
      ids.add(categoryId);
    }
    state = state.copyWith(categoryIds: ids);
  }

  void clear() => state = const TransactionFilter();
}

/// Loaded transactions of [kind]. `null` while the first page loads.
///
/// Most consumers want the rows rather than the paging state, so they watch
/// this instead of unwrapping [TransactionPage] themselves.
@riverpod
List<Transaction>? transactionItems(Ref ref, TransactionKind kind) =>
    ref.watch(transactionListProvider(kind)).value?.items;

/// Filtered + sorted transaction list. `null` while the underlying list loads.
///
/// Filtering applies to the transactions loaded so far — the opening window
/// plus any older pages the user has pulled in.
@riverpod
List<Transaction>? filteredTransactions(Ref ref, TransactionKind kind) {
  final all = ref.watch(transactionItemsProvider(kind));
  if (all == null) return null;
  final filter = ref.watch(transactionFilterControllerProvider(kind));
  final filtered = filter.apply(all);
  filtered.sort((a, b) => b.occurredOn.compareTo(a.occurredOn));
  return filtered;
}

/// Sum of the current month's transactions for [kind], derived from
/// [TransactionList]. Returns `null` while loading / on error.
@riverpod
Money? currentMonthTotal(Ref ref, TransactionKind kind) {
  final transactions = ref.watch(transactionItemsProvider(kind));
  if (transactions == null) return null;
  final month = Month.current();
  return transactions
      .where((t) => month.contains(t.occurredOn))
      .fold<Money>(
        Money.zero(ref.watch(currencyCodeProvider)),
        (sum, t) => sum + t.amount,
      );
}
