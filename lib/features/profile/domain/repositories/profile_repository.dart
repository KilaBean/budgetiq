import '../entities/profile.dart';

/// Contract for reading and updating the current user's profile. Throws a
/// [Failure](../../../../core/error/failure.dart) on error.
abstract interface class ProfileRepository {
  /// The current user's profile, falling back to cache when offline.
  Future<Profile> getProfile();

  /// Updates the user's preferred currency (single-currency MVP).
  Future<Profile> updateCurrency(String currencyCode);
}
