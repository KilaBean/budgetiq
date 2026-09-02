import '../../../../core/cache/cache_box.dart';
import '../../../../shared/domain/transaction_kind.dart';

/// Hive-backed cache of the last-known transaction rows for offline reads.
class TransactionLocalDataSource {
  TransactionLocalDataSource(this._cache);

  final JsonListCache _cache;

  String _key(TransactionKind kind) => 'transactions_${kind.name}';

  List<Map<String, dynamic>> read(TransactionKind kind) =>
      _cache.read(_key(kind));

  Future<void> write(TransactionKind kind, List<Map<String, dynamic>> rows) =>
      _cache.write(_key(kind), rows);
}
