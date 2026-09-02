import '../../../../shared/domain/money.dart';
import '../../../../shared/domain/month.dart';
import '../../../transactions/domain/entities/transaction.dart';

/// Spending share for one category within a period.
class CategorySpend {
  const CategorySpend({
    required this.categoryName,
    required this.amount,
    required this.fraction,
  });

  final String categoryName;
  final Money amount;

  /// Share of the period's total expense, in [0, 1].
  final double fraction;
}

/// Headline figures for a single month, plus month-over-month context.
class DashboardSummary {
  const DashboardSummary({
    required this.month,
    required this.income,
    required this.expense,
    required this.previousExpense,
    required this.topExpenseCategories,
    this.incomeDeltaPct,
    this.expenseDeltaPct,
  });

  final Month month;
  final Money income;
  final Money expense;
  final Money previousExpense;
  final List<CategorySpend> topExpenseCategories;

  /// Percentage change vs the previous month; `null` when there is no prior
  /// data to compare against (avoids divide-by-zero, keeps it explainable).
  final double? incomeDeltaPct;
  final double? expenseDeltaPct;

  Money get net => income - expense;

  /// (income − expense) ÷ income, in fractional form. 0 when no income.
  double get savingsRate {
    if (income.isZero) return 0;
    return net.minorUnits / income.minorUnits;
  }
}

/// Builds a [DashboardSummary] for [month] from full income/expense lists.
/// Pure and deterministic — the unit of dashboard insight tested in isolation.
DashboardSummary buildDashboardSummary({
  required Month month,
  required List<Transaction> income,
  required List<Transaction> expense,
  String currencyCode = 'USD',
}) {
  final previous = month.previous;

  final monthIncome = _sumIn(income, month, currencyCode);
  final monthExpense = _sumIn(expense, month, currencyCode);
  final prevIncome = _sumIn(income, previous, currencyCode);
  final prevExpense = _sumIn(expense, previous, currencyCode);

  return DashboardSummary(
    month: month,
    income: monthIncome,
    expense: monthExpense,
    previousExpense: prevExpense,
    incomeDeltaPct: _deltaPct(prevIncome, monthIncome),
    expenseDeltaPct: _deltaPct(prevExpense, monthExpense),
    topExpenseCategories: _topCategories(expense, month, currencyCode),
  );
}

Money _sumIn(List<Transaction> txns, Month month, String currency) {
  return txns
      .where((t) => month.contains(t.occurredOn))
      .fold(Money.zero(currency), (sum, t) => sum + t.amount);
}

double? _deltaPct(Money previous, Money current) {
  if (previous.isZero) return null;
  return (current.minorUnits - previous.minorUnits) / previous.minorUnits * 100;
}

List<CategorySpend> _topCategories(
  List<Transaction> expense,
  Month month,
  String currency, {
  int limit = 5,
}) {
  final byCategory = <String, Money>{};
  for (final tx in expense.where((t) => month.contains(t.occurredOn))) {
    final name = tx.categoryName ?? 'Uncategorized';
    byCategory[name] = (byCategory[name] ?? Money.zero(currency)) + tx.amount;
  }

  final total = byCategory.values.fold(
    Money.zero(currency),
    (sum, m) => sum + m,
  );

  final entries = byCategory.entries.toList()
    ..sort((a, b) => b.value.minorUnits.compareTo(a.value.minorUnits));

  return entries
      .take(limit)
      .map(
        (e) => CategorySpend(
          categoryName: e.key,
          amount: e.value,
          fraction: total.isZero ? 0 : e.value.minorUnits / total.minorUnits,
        ),
      )
      .toList();
}
