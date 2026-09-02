import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the amount validator logic used in TransactionFormSheet.
/// The validator is defined inline in the widget; we test the equivalent
/// pure function here to avoid a full widget / Riverpod setup.

String? _validateAmount(String? input) {
  final value = double.tryParse(input ?? '');
  if (value == null) return 'Enter a valid amount.';
  if (value <= 0) return 'Amount must be greater than zero.';
  return null;
}

void main() {
  group('Transaction amount validator', () {
    test('accepts a positive integer amount', () {
      expect(_validateAmount('100'), isNull);
    });

    test('accepts a positive decimal amount', () {
      expect(_validateAmount('9.99'), isNull);
    });

    test('accepts the minimum positive value', () {
      expect(_validateAmount('0.01'), isNull);
    });

    test('rejects empty input', () {
      expect(_validateAmount(''), isNotNull);
      expect(_validateAmount(null), isNotNull);
    });

    test('rejects non-numeric text', () {
      expect(_validateAmount('abc'), isNotNull);
      expect(_validateAmount('12.34.56'), isNotNull);
    });

    test('rejects zero', () {
      expect(_validateAmount('0'), isNotNull);
      expect(_validateAmount('0.00'), isNotNull);
    });

    test('rejects negative amounts', () {
      expect(_validateAmount('-5'), isNotNull);
      expect(_validateAmount('-0.01'), isNotNull);
    });

    test('error message for zero is correct', () {
      expect(_validateAmount('0'), 'Amount must be greater than zero.');
    });

    test('error message for invalid input is correct', () {
      expect(_validateAmount('not-a-number'), 'Enter a valid amount.');
    });
  });
}
