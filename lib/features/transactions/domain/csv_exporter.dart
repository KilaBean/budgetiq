import 'package:intl/intl.dart';

import 'entities/transaction.dart';
import '../../../shared/domain/transaction_kind.dart';

/// Converts a list of transactions to a CSV string.
///
/// Columns: Date, Type, Amount, Currency, Category, Note
/// Amounts are always positive; Type column indicates direction.
String buildTransactionCsv(List<Transaction> transactions) {
  final buf = StringBuffer();
  buf.writeln('Date,Type,Amount,Currency,Category,Note');

  final sorted = [...transactions]
    ..sort((a, b) => b.occurredOn.compareTo(a.occurredOn));

  for (final tx in sorted) {
    buf.writeln(
      [
        DateFormat('yyyy-MM-dd').format(tx.occurredOn),
        tx.kind == TransactionKind.income ? 'Income' : 'Expense',
        tx.amount.major.toStringAsFixed(2),
        tx.amount.currencyCode,
        _csvField(tx.categoryName ?? 'Uncategorized'),
        _csvField(tx.note ?? ''),
      ].join(','),
    );
  }

  return buf.toString();
}

/// Wraps a field in double-quotes and escapes internal quotes per RFC 4180.
String _csvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
