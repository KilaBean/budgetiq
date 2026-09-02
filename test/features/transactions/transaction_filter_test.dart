import 'package:budgetiq/features/transactions/domain/entities/transaction.dart';
import 'package:budgetiq/features/transactions/domain/transaction_filter.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Transaction _tx({
  required String id,
  required DateTime occurredOn,
  String? categoryId,
}) => Transaction(
  id: id,
  kind: TransactionKind.expense,
  amount: Money.fromMajor(10),
  occurredOn: occurredOn,
  categoryId: categoryId,
);

void main() {
  final groceries = _tx(
    id: 'a',
    occurredOn: DateTime(2026, 6, 10),
    categoryId: 'c1',
  );
  final transport = _tx(
    id: 'b',
    occurredOn: DateTime(2026, 6, 20),
    categoryId: 'c2',
  );
  final uncategorized = _tx(id: 'c', occurredOn: DateTime(2026, 7, 1));
  final all = [groceries, transport, uncategorized];

  group('isActive / activeCount', () {
    test('an empty filter is inactive', () {
      const filter = TransactionFilter();
      expect(filter.isActive, isFalse);
      expect(filter.activeCount, 0);
    });

    test('each dimension counts once', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          start: DateTime(2026, 6),
          end: DateTime(2026, 6, 30),
        ),
        categoryIds: const {'c1', 'c2'},
      );
      expect(filter.isActive, isTrue);
      expect(filter.activeCount, 2);
    });
  });

  group('apply', () {
    test('no criteria keeps everything', () {
      expect(const TransactionFilter().apply(all), all);
    });

    test('date range is inclusive of both endpoints', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          start: DateTime(2026, 6, 10),
          end: DateTime(2026, 6, 20),
        ),
      );
      expect(filter.apply(all), [groceries, transport]);
    });

    test('range comparison ignores the time of day', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          // A picker returns "now" on the chosen day, not midnight.
          start: DateTime(2026, 6, 20, 18, 30),
          end: DateTime(2026, 6, 20, 18, 30),
        ),
      );
      expect(filter.apply(all), [transport]);
    });

    test('categories filter to the selected ids', () {
      const filter = TransactionFilter(categoryIds: {'c2'});
      expect(filter.apply(all), [transport]);
    });

    test('an uncategorized transaction is excluded by any category filter', () {
      const filter = TransactionFilter(categoryIds: {'c1'});
      expect(filter.apply(all), isNot(contains(uncategorized)));
    });

    test('criteria combine', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          start: DateTime(2026, 6),
          end: DateTime(2026, 6, 30),
        ),
        categoryIds: const {'c1'},
      );
      expect(filter.apply(all), [groceries]);
    });
  });

  group('copyWith', () {
    test('omitting a field keeps it', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          start: DateTime(2026, 6),
          end: DateTime(2026, 6, 30),
        ),
        categoryIds: const {'c1'},
      );

      final updated = filter.copyWith(categoryIds: const {'c2'});

      expect(updated.dateRange, filter.dateRange);
      expect(updated.categoryIds, {'c2'});
    });

    test('passing null clears the range, unlike omitting it', () {
      final filter = TransactionFilter(
        dateRange: DateTimeRange(
          start: DateTime(2026, 6),
          end: DateTime(2026, 6, 30),
        ),
      );

      expect(filter.copyWith(dateRange: null).dateRange, isNull);
      expect(filter.copyWith().dateRange, isNotNull);
    });
  });
}
