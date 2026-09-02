import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/observability/app_logger.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/sync/remote_sync_api.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
SyncQueue syncQueue(Ref ref) => SyncQueue(ref.watch(jsonListCacheProvider));

@Riverpod(keepAlive: true)
SyncEngine syncEngine(Ref ref) {
  final queue = ref.watch(syncQueueProvider);
  return SyncEngine(
    queue: queue,
    remote: SupabaseRemoteSyncApi(ref.watch(supabaseClientProvider)),
    // A permanently-rejected write is a change the user believes they saved.
    // Log it, keep it as a dead letter, and let the UI say so.
    onPermanentFailure: (op, error, stackTrace) async {
      AppLogger.error(error, stackTrace: stackTrace, context: 'sync-rejected');
      await queue.recordDeadLetter(op, _describeFailure(error));
    },
  );
}

/// A short, user-readable reason a write was rejected.
String _describeFailure(Object error) {
  if (error is PostgrestException) return error.message;
  if (error is AuthException) return error.message;
  return error.toString();
}

/// Observable sync status for the UI.
class SyncStatus {
  const SyncStatus({
    required this.pending,
    required this.isSyncing,
    this.failed = 0,
  });

  final int pending;
  final bool isSyncing;

  /// Changes the server rejected outright, still awaiting acknowledgement.
  final int failed;

  bool get hasPending => pending > 0;

  bool get hasFailures => failed > 0;

  SyncStatus copyWith({int? pending, bool? isSyncing, int? failed}) =>
      SyncStatus(
        pending: pending ?? this.pending,
        isSyncing: isSyncing ?? this.isSyncing,
        failed: failed ?? this.failed,
      );
}

/// Coordinates draining the offline queue: on startup, and whenever
/// connectivity is regained. After a successful drain it refreshes the
/// transaction lists so server-reconciled data replaces optimistic local rows.
@Riverpod(keepAlive: true)
class SyncController extends _$SyncController {
  bool _retryScheduled = false;

  @override
  SyncStatus build() {
    // Auto-sync when connectivity returns.
    ref.listen(connectivityStatusProvider, (previous, next) {
      if (next.value == true) sync();
    });

    // Attempt an initial drain shortly after startup.
    Future.microtask(sync);

    final queue = ref.read(syncQueueProvider);
    return SyncStatus(
      pending: queue.length,
      isSyncing: false,
      failed: queue.deadLetterCount,
    );
  }

  /// Drains the queue if online. Idempotent and safe to call repeatedly. If
  /// work remains afterwards (e.g. a transient failure while the connection is
  /// still settling), a retry is scheduled so pending changes don't get stuck.
  Future<void> sync() async {
    if (state.isSyncing) return;
    if (!ref.read(isOnlineProvider)) {
      state = state.copyWith(pending: ref.read(syncQueueProvider).length);
      return;
    }

    state = state.copyWith(isSyncing: true);
    SyncResult result;
    try {
      result = await ref.read(syncEngineProvider).drain();
    } catch (e, st) {
      // drain() shouldn't throw, but never leave the UI stuck on "syncing".
      AppLogger.error(e, stackTrace: st, context: 'sync');
      result = SyncResult(
        synced: 0,
        remaining: ref.read(syncQueueProvider).length,
      );
    }
    state = SyncStatus(
      pending: result.remaining,
      isSyncing: false,
      failed: ref.read(syncQueueProvider).deadLetterCount,
    );

    if (result.synced > 0) {
      ref.invalidate(transactionListProvider(TransactionKind.income));
      ref.invalidate(transactionListProvider(TransactionKind.expense));
      ref.invalidate(categoryListProvider(TransactionKind.income));
      ref.invalidate(categoryListProvider(TransactionKind.expense));
      ref.invalidate(goalListProvider);
      ref.invalidate(currentBudgetProvider);
    }

    // Still have queued work while online? Retry shortly — handles a reconnect
    // where the first attempt failed because the network hadn't settled.
    if (result.remaining > 0 && ref.read(isOnlineProvider)) {
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (_retryScheduled) return;
    _retryScheduled = true;
    Future.delayed(const Duration(seconds: 8), () {
      _retryScheduled = false;
      sync();
    });
  }

  /// Acknowledges rejected changes, clearing the failure banner.
  Future<void> dismissFailures() async {
    await ref.read(syncQueueProvider).clearDeadLetters();
    state = state.copyWith(failed: 0);
  }

  /// Reflects a newly enqueued op in the status (called by repositories).
  void notifyEnqueued() {
    state = state.copyWith(pending: ref.read(syncQueueProvider).length);
    sync();
  }
}
