import 'transaction.dart';

/// A window of transactions held by the UI, plus whether older ones exist.
///
/// Transactions are never loaded in full: the app opens on a rolling window
/// (see `kTransactionWindowMonths`) that covers every analytic, and older
/// history is paged in on demand.
class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  const TransactionPage.empty()
    : items = const [],
      hasMore = false,
      isLoadingMore = false;

  /// Loaded transactions, newest first.
  final List<Transaction> items;

  /// Whether history older than [items] exists on the server.
  final bool hasMore;

  /// Whether an older page is currently being fetched.
  final bool isLoadingMore;

  TransactionPage copyWith({
    List<Transaction>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) => TransactionPage(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}
