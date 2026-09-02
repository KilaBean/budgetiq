import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../entities/transaction.dart';
import '../entities/transaction_page.dart';

/// Contract for reading and managing transactions. Implementations throw a
/// [Failure](../../../../core/error/failure.dart) on error.
abstract interface class TransactionRepository {
  /// A page of active (non-deleted) transactions of [kind], newest first,
  /// falling back to cache when offline.
  ///
  /// With no [olderThan] this loads the rolling window the app opens on;
  /// passing the oldest loaded date returns the next page of older history.
  Future<TransactionPage> getTransactions(
    TransactionKind kind, {
    DateTime? olderThan,
  });

  Future<Transaction> createTransaction({
    required TransactionKind kind,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  });

  Future<Transaction> updateTransaction({
    required Transaction original,
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  });

  Future<void> deleteTransaction(Transaction transaction);
}
