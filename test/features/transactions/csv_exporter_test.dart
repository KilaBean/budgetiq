import 'package:budgetiq/features/transactions/domain/csv_exporter.dart';
import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required TransactionKind kind,
  required double amount,
  required DateTime date,
  String? categoryName,
  String? note,
}) => Transaction(
  id: id,
  kind: kind,
  amount: Money.fromMajor(amount, currencyCode: 'USD'),
  occurredOn: date,
  categoryName: categoryName,
  note: note,
);

void main() {
  group('buildTransactionCsv', () {
    test('produces header row', () {
      final csv = buildTransactionCsv([]);
      expect(
        csv.trim().split('\n').first,
        'Date,Type,Amount,Currency,Category,Note',
      );
    });

    test('empty transaction list produces only header', () {
      final csv = buildTransactionCsv([]);
      expect(csv.trim().split('\n').length, 1);
    });

    test('income transaction has correct Type column', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.income,
          amount: 500,
          date: DateTime(2026, 6, 1),
        ),
      ]);
      final row = csv.trim().split('\n')[1];
      expect(row, contains('Income'));
    });

    test('expense transaction has correct Type column', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 99.99,
          date: DateTime(2026, 6, 5),
        ),
      ]);
      final row = csv.trim().split('\n')[1];
      expect(row, contains('Expense'));
    });

    test('amount is formatted to 2 decimal places', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 42,
          date: DateTime(2026, 6, 1),
        ),
      ]);
      expect(csv, contains('42.00'));
    });

    test('date is formatted as yyyy-MM-dd', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.income,
          amount: 100,
          date: DateTime(2026, 6, 15),
        ),
      ]);
      expect(csv, contains('2026-06-15'));
    });

    test('category name defaults to Uncategorized when null', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 10,
          date: DateTime(2026, 6, 1),
        ),
      ]);
      expect(csv, contains('Uncategorized'));
    });

    test('note field is included when present', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 20,
          date: DateTime(2026, 6, 1),
          note: 'Coffee run',
        ),
      ]);
      expect(csv, contains('Coffee run'));
    });

    test('fields containing commas are wrapped in quotes', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 30,
          date: DateTime(2026, 6, 1),
          categoryName: 'Food, Dining',
        ),
      ]);
      expect(csv, contains('"Food, Dining"'));
    });

    test('fields containing double-quotes escape them per RFC 4180', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.expense,
          amount: 5,
          date: DateTime(2026, 6, 1),
          note: 'Said "hello"',
        ),
      ]);
      expect(csv, contains('"Said ""hello"""'));
    });

    test('transactions are sorted newest first', () {
      final csv = buildTransactionCsv([
        _tx(
          id: 'old',
          kind: TransactionKind.income,
          amount: 100,
          date: DateTime(2026, 5, 1),
        ),
        _tx(
          id: 'new',
          kind: TransactionKind.income,
          amount: 200,
          date: DateTime(2026, 6, 1),
        ),
      ]);
      final rows = csv.trim().split('\n');
      expect(rows[1], contains('2026-06-01'));
      expect(rows[2], contains('2026-05-01'));
    });

    test('multiple transactions produce correct row count', () {
      final csv = buildTransactionCsv([
        _tx(
          id: '1',
          kind: TransactionKind.income,
          amount: 100,
          date: DateTime(2026, 6, 1),
        ),
        _tx(
          id: '2',
          kind: TransactionKind.expense,
          amount: 50,
          date: DateTime(2026, 6, 2),
        ),
        _tx(
          id: '3',
          kind: TransactionKind.expense,
          amount: 25,
          date: DateTime(2026, 6, 3),
        ),
      ]);
      // 1 header + 3 data rows
      expect(csv.trim().split('\n').length, 4);
    });
  });
}
