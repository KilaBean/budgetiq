import '../../domain/entities/profile.dart';

/// Maps profile rows between Supabase/JSON and the [Profile] entity.
class ProfileModel {
  const ProfileModel._();

  static Profile fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    currencyCode: (json['currency_code'] as String?) ?? 'USD',
    displayName: json['display_name'] as String?,
    locale: (json['locale'] as String?) ?? 'en_US',
    themeMode: (json['theme_mode'] as String?) ?? 'system',
    largeText: (json['large_text'] as bool?) ?? false,
  );

  static Map<String, dynamic> toJson(Profile p) => {
    'id': p.id,
    'currency_code': p.currencyCode,
    'display_name': p.displayName,
    'locale': p.locale,
    'theme_mode': p.themeMode,
    'large_text': p.largeText,
  };
}
