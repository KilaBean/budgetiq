import 'package:equatable/equatable.dart';

/// The signed-in user's profile (1:1 with the auth user).
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.currencyCode,
    this.displayName,
    this.locale = 'en_US',
    this.themeMode = 'system',
    this.largeText = false,
  });

  final String id;
  final String currencyCode;
  final String? displayName;
  final String locale;
  final String themeMode;
  final bool largeText;

  @override
  List<Object?> get props => [
    id,
    currencyCode,
    displayName,
    locale,
    themeMode,
    largeText,
  ];
}
