import '../../../../core/cache/cache_box.dart';

/// Hive-backed cache of a month's budget JSON, enabling offline reads.
///
/// A budget is stored as a 0- or 1-element list under its period key so it can
/// reuse [JsonListCache].
class BudgetLocalDataSource {
  BudgetLocalDataSource(this._cache);

  final JsonListCache _cache;

  String _key(String periodStart) => 'budget_$periodStart';

  Map<String, dynamic>? read(String periodStart) {
    final rows = _cache.read(_key(periodStart));
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> write(String periodStart, Map<String, dynamic>? budget) =>
      _cache.write(_key(periodStart), budget == null ? [] : [budget]);
}
