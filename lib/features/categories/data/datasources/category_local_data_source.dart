import '../../../../core/cache/cache_box.dart';
import '../../../../shared/domain/transaction_kind.dart';

/// Hive-backed cache of the last-known category rows, enabling offline reads.
class CategoryLocalDataSource {
  CategoryLocalDataSource(this._cache);

  final JsonListCache _cache;

  String _key(TransactionKind kind) => 'categories_${kind.name}';

  List<Map<String, dynamic>> read(TransactionKind kind) =>
      _cache.read(_key(kind));

  Future<void> write(TransactionKind kind, List<Map<String, dynamic>> rows) =>
      _cache.write(_key(kind), rows);
}
