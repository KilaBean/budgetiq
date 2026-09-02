import 'package:equatable/equatable.dart';

/// Base type for all domain-level errors surfaced to the presentation layer.
///
/// The data layer is responsible for translating low-level exceptions
/// (network, auth, storage) into a [Failure] so the UI never depends on
/// implementation details such as Supabase exceptions.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable, user-safe message.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Authentication / authorization related failure.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Network connectivity or server-side failure.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Local validation failure (invalid input before hitting the backend).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// The user deliberately aborted a flow (e.g. dismissed the Google account
/// picker). Not an error condition — the UI should return to idle silently.
class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Sign-in cancelled.']);
}

/// Unexpected/unhandled failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}

/// Extracts a user-facing message from any error object, preferring
/// [Failure.message] when available.
String messageFromError(Object error) =>
    error is Failure ? error.message : 'Something went wrong.';
