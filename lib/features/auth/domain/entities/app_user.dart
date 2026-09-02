import 'package:equatable/equatable.dart';

/// Authenticated user as understood by the domain layer.
///
/// Intentionally minimal and decoupled from Supabase's `User` type so the rest
/// of the app never depends on the auth provider's data shape.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.email,
    this.emailConfirmed = false,
  });

  final String id;
  final String email;
  final bool emailConfirmed;

  @override
  List<Object?> get props => [id, email, emailConfirmed];
}
