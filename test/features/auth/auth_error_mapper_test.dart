import 'package:budgetiq/features/auth/data/auth_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapAuthError', () {
    test('maps invalid credentials', () {
      expect(
        mapAuthError(const AuthException('Invalid login credentials')),
        'Email or password is incorrect.',
      );
      expect(
        mapAuthError(const AuthException('x', code: 'invalid_credentials')),
        'Email or password is incorrect.',
      );
    });

    test('maps unconfirmed email', () {
      expect(
        mapAuthError(const AuthException('Email not confirmed')),
        contains('confirm your email'),
      );
    });

    test('maps already-registered', () {
      expect(
        mapAuthError(const AuthException('User already registered')),
        contains('already exists'),
      );
    });

    test('maps rate limiting', () {
      expect(
        mapAuthError(
          const AuthException('x', code: 'over_email_send_rate_limit'),
        ),
        contains('Too many attempts'),
      );
    });

    test('falls back to a safe generic message', () {
      expect(
        mapAuthError(const AuthException('some obscure internal error')),
        'Something went wrong. Please try again.',
      );
    });
  });

  test('maps OAuth/identity errors to friendly copy', () {
    expect(
      mapAuthError(const AuthException('x', code: 'identity_already_exists')),
      'This Google account is already linked to another user.',
    );
    expect(
      mapAuthError(const AuthException('x', code: 'provider_disabled')),
      'Google sign-in is not enabled for this app yet.',
    );
    expect(
      mapAuthError(const AuthException('x', code: 'bad_jwt')),
      'Google sign-in could not be verified. Please try again.',
    );
  });
}
