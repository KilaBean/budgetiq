import 'package:budgetiq/shared/domain/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money construction', () {
    test('fromMajor rounds to nearest minor unit', () {
      expect(Money.fromMajor(12.345).minorUnits, 1235);
      expect(Money.fromMajor(12.344).minorUnits, 1234);
    });

    test('fromDatabase parses num and String', () {
      expect(Money.fromDatabase(10.5).minorUnits, 1050);
      expect(Money.fromDatabase('10.50').minorUnits, 1050);
    });

    test('zero is zero', () {
      expect(Money.zero().isZero, isTrue);
      expect(Money.zero().isPositive, isFalse);
    });
  });

  group('Money arithmetic', () {
    test('adds and subtracts within same currency', () {
      final a = Money.fromMajor(10);
      final b = Money.fromMajor(2.5);
      expect((a + b).major, 12.5);
      expect((a - b).major, 7.5);
    });

    test('mixed currencies combine on minor units (single-currency app)', () {
      // Arithmetic keeps the left operand's currency and never throws, so older
      // rows with a stale currency code can't crash aggregations.
      final usd = Money.fromMajor(1, currencyCode: 'USD');
      final eur = Money.fromMajor(2, currencyCode: 'EUR');
      final sum = usd + eur;
      expect(sum.minorUnits, 300);
      expect(sum.currencyCode, 'USD');
    });

    test('compares by amount', () {
      expect(Money.fromMajor(5).compareTo(Money.fromMajor(10)), lessThan(0));
    });
  });

  group('Money formatting', () {
    test('formats USD with symbol', () {
      final formatted = Money.fromMajor(1234.5).format(locale: 'en_US');
      expect(formatted.contains('1,234.50'), isTrue);
    });
  });
}
