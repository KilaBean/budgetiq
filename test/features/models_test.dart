import 'package:budgetiq/features/categories/data/models/category_model.dart';
import 'package:budgetiq/features/categories/domain/entities/category.dart';
import 'package:budgetiq/features/transactions/data/models/transaction_model.dart';
import 'package:budgetiq/shared/domain/money.dart';
import 'package:budgetiq/shared/domain/transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel', () {
    test('fromJson maps fields', () {
      final c = CategoryModel.fromJson({
        'id': '1',
        'name': 'Food',
        'icon': 'restaurant',
        'is_system': true,
      }, TransactionKind.expense);
      expect(c.name, 'Food');
      expect(c.kind, TransactionKind.expense);
      expect(c.isSystem, isTrue);
    });

    test('toInsert / toUpdate include the writable fields', () {
      const c = Category(
        id: '1',
        kind: TransactionKind.income,
        name: 'Salary',
        icon: 'payments',
      );
      final insert = CategoryModel.toInsert(c, 'user-1');
      expect(insert['user_id'], 'user-1');
      expect(insert['name'], 'Salary');

      final update = CategoryModel.toUpdate(c);
      expect(update.containsKey('user_id'), isFalse);
      expect(update['name'], 'Salary');
    });
  });

  group('TransactionModel', () {
    test('fromJson uses the active currency and embedded category name', () {
      final t = TransactionModel.fromJson(
        {
          'id': 't1',
          'amount': 12.5,
          'currency_code': 'USD', // stored code is ignored…
          'occurred_on': '2026-06-10',
          'note': 'lunch',
          'category_id': 'c1',
          'expense_categories': {'name': 'Food'},
        },
        TransactionKind.expense,
        'GHS', // …in favor of the active currency
      );
      expect(t.amount, Money.fromMajor(12.5, currencyCode: 'GHS'));
      expect(t.categoryName, 'Food');
      expect(t.note, 'lunch');
    });

    test('toWrite normalizes a blank note to null and formats the date', () {
      final data = TransactionModel.toWrite(
        amount: Money.fromMajor(20, currencyCode: 'USD'),
        occurredOn: DateTime(2026, 1, 5),
        categoryId: 'c1',
        note: '   ',
      );
      expect(data['occurred_on'], '2026-01-05');
      expect(data['note'], isNull);
      expect(data['amount'], 20.0);
    });
  });
}
