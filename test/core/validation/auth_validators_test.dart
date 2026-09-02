import 'package:budgetiq/core/validation/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthValidators.email', () {
    test('rejects empty input', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email(null), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.email('foo@bar'), isNotNull);
    });

    test('accepts a valid address', () {
      expect(AuthValidators.email('user@example.com'), isNull);
      expect(AuthValidators.email('  user@example.com  '), isNull);
    });
  });

  group('AuthValidators.password', () {
    test('rejects short passwords', () {
      expect(AuthValidators.password('short'), isNotNull);
    });

    test('accepts sufficiently long passwords', () {
      expect(AuthValidators.password('longenough1'), isNull);
    });
  });

  group('AuthValidators.confirmPassword', () {
    test('rejects mismatch', () {
      expect(AuthValidators.confirmPassword('abc', 'xyz'), isNotNull);
    });

    test('accepts match', () {
      expect(AuthValidators.confirmPassword('abc12345', 'abc12345'), isNull);
    });
  });
}
