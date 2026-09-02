import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/domain/transaction_kind.dart';

/// Read access to transaction tables, embedding the related category name.
///
/// Writes go through the offline sync outbox (see core/sync), not this class,
/// so reads are all that's needed here.
class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._client);

  final SupabaseClient _client;

  String _selectColumns(TransactionKind kind) =>
      'id, amount, currency_code, occurred_on, note, category_id, updated_at, '
      '${kind.categoryTable}(name, icon, color)';

  /// Fetches rows of [kind], newest first.
  ///
  /// [from] bounds the query below (inclusive) and [to] above (inclusive), so
  /// the app can load a rolling window rather than a user's whole history.
  /// [limit] caps the row count.
  Future<List<Map<String, dynamic>>> fetch(
    TransactionKind kind, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    var filter = _client
        .from(kind.transactionTable)
        .select(_selectColumns(kind))
        .isFilter('deleted_at', null);
    if (from != null) filter = filter.gte('occurred_on', _dateOnly(from));
    if (to != null) filter = filter.lte('occurred_on', _dateOnly(to));

    var query = filter
        .order('occurred_on', ascending: false)
        .order('created_at', ascending: false);
    if (limit != null) query = query.limit(limit);
    return query;
  }

  /// Whether any transaction of [kind] occurred before [date] — used to decide
  /// if a "load older" affordance is worth showing.
  Future<bool> hasBefore(TransactionKind kind, DateTime date) async {
    final rows = await _client
        .from(kind.transactionTable)
        .select('id')
        .isFilter('deleted_at', null)
        .lt('occurred_on', _dateOnly(date))
        .limit(1);
    return rows.isNotEmpty;
  }

  /// `yyyy-MM-dd` for a Postgres `date` column.
  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
