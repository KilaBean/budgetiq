import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/transaction_kind.dart';
import '../../domain/entities/transaction.dart';

/// Maps transaction rows between Supabase/JSON and the [Transaction] entity.
///
/// Reads embed the related category row under the category table key (a
/// Supabase foreign-table select), used to populate [Transaction.categoryName].
class TransactionModel {
  const TransactionModel._();

  /// [currencyCode] is the user's active currency; amounts are displayed in it
  /// (single-currency app), regardless of the row's stored currency code.
  static Transaction fromJson(
    Map<String, dynamic> json,
    TransactionKind kind,
    String currencyCode,
  ) {
    final embeddedCategory = json[kind.categoryTable];
    final category = embeddedCategory is Map ? embeddedCategory : null;
    return Transaction(
      id: json['id'] as String,
      kind: kind,
      amount: Money.fromDatabase(
        json['amount'] as Object,
        currencyCode: currencyCode,
      ),
      occurredOn: DateTime.parse(json['occurred_on'] as String),
      categoryId: json['category_id'] as String?,
      categoryName: category?['name'] as String?,
      categoryIcon: category?['icon'] as String?,
      categoryColor: category?['color'] as String?,
      note: json['note'] as String?,
    );
  }

  static Map<String, dynamic> toWrite({
    required Money amount,
    required DateTime occurredOn,
    String? categoryId,
    String? note,
  }) {
    return {
      'amount': amount.major,
      'currency_code': amount.currencyCode,
      'occurred_on': _dateOnly(occurredOn),
      'category_id': categoryId,
      'note': note?.trim().isEmpty ?? true ? null : note!.trim(),
    };
  }

  /// `yyyy-MM-dd` for a Postgres `date` column.
  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
