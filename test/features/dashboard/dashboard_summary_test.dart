import 'package:budgetiq/features/dashboard/domain/services/dashboard_summary.dart';
import 'package:budgetiq/features/dashboard/domain/services/monthly_trend.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx(
  TransactionKind kind,
  double amount,
  DateTime on, {
  String? category,
}) => Transaction(
  id: '${kind.name}-$amount-${on.millisecondsSinceEpoch}',
  kind: kind,
  amount: Money.fromMajor(amount),
  occurredOn: on,
  categoryName: category,
);

void main() {
  const june = Month(2026, 6);

  group('buildDashboardSummary', () {
    test('computes net and savings rate', () {
      final summary = buildDashboardSummary(
        month: june,
        income: [_tx(TransactionKind.income, 4000, DateTime(2026, 6, 1))],
        expense: [_tx(TransactionKind.expense, 1000, DateTime(2026, 6, 5))],
      );
      expect(summary.income, Money.fromMajor(4000));
      expect(summary.expense, Money.fromMajor(1000));
      expect(summary.net, Money.fromMajor(3000));
      expect(summary.savingsRate, closeTo(0.75, 0.0001));
    });

    test('month-over-month expense delta is a percentage', () {
      final summary = buildDashboardSummary(
        month: june,
        income: const [],
        expense: [
          _tx(TransactionKind.expense, 500, DateTime(2026, 5, 10)), // prev
          _tx(TransactionKind.expense, 590, DateTime(2026, 6, 10)), // current
        ],
      );
      // (590 - 500) / 500 = 18%
      expect(summary.expenseDeltaPct, closeTo(18, 0.0001));
    });

    test('delta is null when there is no prior month', () {
      final summary = buildDashboardSummary(
        month: june,
        income: [_tx(TransactionKind.income, 100, DateTime(2026, 6, 1))],
        expense: const [],
      );
      expect(summary.incomeDeltaPct, isNull);
    });

    test('top categories ranked with fractions summing sensibly', () {
      final summary = buildDashboardSummary(
        month: june,
        income: const [],
        expense: [
          _tx(
            TransactionKind.expense,
            300,
            DateTime(2026, 6, 1),
            category: 'Food',
          ),
          _tx(
            TransactionKind.expense,
            100,
            DateTime(2026, 6, 2),
            category: 'Transport',
          ),
        ],
      );
      expect(summary.topExpenseCategories.first.categoryName, 'Food');
      expect(summary.topExpenseCategories.first.fraction, closeTo(0.75, 0.001));
      expect(summary.savingsRate, 0); // no income → guarded
    });

    test('zero income yields zero savings rate (no divide-by-zero)', () {
      final summary = buildDashboardSummary(
        month: june,
        income: const [],
        expense: [_tx(TransactionKind.expense, 50, DateTime(2026, 6, 1))],
      );
      expect(summary.savingsRate, 0);
    });
  });

  group('buildMonthlyTrend', () {
    test('produces a contiguous oldest-first series of fixed length', () {
      final trend = buildMonthlyTrend(
        income: [_tx(TransactionKind.income, 200, DateTime(2026, 6, 1))],
        expense: [_tx(TransactionKind.expense, 80, DateTime(2026, 4, 1))],
        months: 6,
        anchor: june,
      );
      expect(trend.length, 6);
      expect(trend.first.month, const Month(2026, 1));
      expect(trend.last.month, june);
      // April expense and June income land in the right buckets.
      expect(trend[3].expense, Money.fromMajor(80)); // April
      expect(trend.last.income, Money.fromMajor(200)); // June
    });
  });
}
