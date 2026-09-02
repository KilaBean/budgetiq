import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/month.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the currentMonthTotal derived value logic.
/// We test the pure computation (filter + fold) rather than the Riverpod
/// provider itself, which would require a full ProviderContainer setup
/// with Supabase stubs.

Money _sumForMonth(List<Transaction> all, Month month, TransactionKind kind) {
  return all
      .where((t) => t.kind == kind && month.contains(t.occurredOn))
      .fold<Money>(Money.zero('USD'), (sum, t) => sum + t.amount);
}

Transaction _tx(TransactionKind kind, double amount, DateTime date) =>
    Transaction(
      id: 'id-$amount-${date.millisecondsSinceEpoch}',
      kind: kind,
      amount: Money.fromMajor(amount),
      occurredOn: date,
    );

void main() {
  final june = const Month(2026, 6);

  group('currentMonthTotal logic', () {
    test('sums only current-month transactions', () {
      final transactions = [
        _tx(TransactionKind.income, 1000, DateTime(2026, 6, 1)),
        _tx(TransactionKind.income, 500, DateTime(2026, 6, 15)),
        _tx(TransactionKind.income, 200, DateTime(2026, 5, 31)), // prior month
      ];

      final total = _sumForMonth(transactions, june, TransactionKind.income);
      expect(total, Money.fromMajor(1500));
    });

    test('returns zero when no transactions match current month', () {
      final transactions = [
        _tx(TransactionKind.income, 1000, DateTime(2026, 5, 1)),
      ];

      final total = _sumForMonth(transactions, june, TransactionKind.income);
      expect(total.isZero, isTrue);
    });

    test('filters by kind — income excludes expenses', () {
      final transactions = [
        _tx(TransactionKind.income, 800, DateTime(2026, 6, 10)),
        _tx(TransactionKind.expense, 300, DateTime(2026, 6, 10)),
      ];

      final income = _sumForMonth(transactions, june, TransactionKind.income);
      final expenses = _sumForMonth(
        transactions,
        june,
        TransactionKind.expense,
      );

      expect(income, Money.fromMajor(800));
      expect(expenses, Money.fromMajor(300));
    });

    test('handles empty list', () {
      final total = _sumForMonth([], june, TransactionKind.expense);
      expect(total.isZero, isTrue);
    });

    test('includes transactions on first and last day of month', () {
      final transactions = [
        _tx(TransactionKind.expense, 100, DateTime(2026, 6, 1)),
        _tx(TransactionKind.expense, 200, DateTime(2026, 6, 30)),
        _tx(TransactionKind.expense, 999, DateTime(2026, 7, 1)), // next month
      ];

      final total = _sumForMonth(transactions, june, TransactionKind.expense);
      expect(total, Money.fromMajor(300));
    });
  });
}
