import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Income and expense totals for one month in a trend series.
class MonthlyTotals {
  const MonthlyTotals({
    required this.month,
    required this.income,
    required this.expense,
  });

  final Month month;
  final Money income;
  final Money expense;

  Money get net => income - expense;
}

/// Builds a contiguous trend of the last [months] months ending at [anchor]
/// (default: current month), oldest first. Months with no activity are
/// included as zeroes so charts render a continuous axis.
List<MonthlyTotals> buildMonthlyTrend({
  required List<Transaction> income,
  required List<Transaction> expense,
  int months = 6,
  Month? anchor,
  String currencyCode = 'USD',
}) {
  final end = anchor ?? Month.current();

  // Walk back to the first month, then forward to build oldest→newest.
  var cursor = end;
  for (var i = 1; i < months; i++) {
    cursor = cursor.previous;
  }

  final series = <MonthlyTotals>[];
  for (var i = 0; i < months; i++) {
    series.add(
      MonthlyTotals(
        month: cursor,
        income: _sumIn(income, cursor, currencyCode),
        expense: _sumIn(expense, cursor, currencyCode),
      ),
    );
    cursor = cursor.next;
  }
  return series;
}

Money _sumIn(List<Transaction> txns, Month month, String currency) {
  return txns
      .where((t) => month.contains(t.occurredOn))
      .fold(Money.zero(currency), (sum, t) => sum + t.amount);
}
