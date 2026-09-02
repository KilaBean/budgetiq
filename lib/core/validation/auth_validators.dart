/// Pure, testable validation helpers for authentication input.
///
/// Returns `null` when valid, or a user-facing error string when invalid —
/// matching the signature expected by Flutter `FormField.validator`.
class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  static const int minPasswordLength = 8;

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Email is required.';
    if (!_emailRegex.hasMatch(input)) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return 'Password is required.';
    if (input.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }
}
