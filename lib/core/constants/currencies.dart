/// A supported currency option for the single-currency MVP.
class CurrencyOption {
  const CurrencyOption(this.code, this.name);
  final String code;
  final String name;
}

/// Currencies offered at onboarding and in profile settings. Kept short and
/// extendable; formatting is driven by the code via `intl`.
const List<CurrencyOption> kSupportedCurrencies = [
  CurrencyOption('USD', 'US Dollar'),
  CurrencyOption('EUR', 'Euro'),
  CurrencyOption('GBP', 'British Pound'),
  CurrencyOption('GHS', 'Ghanaian Cedi'),
  CurrencyOption('NGN', 'Nigerian Naira'),
  CurrencyOption('KES', 'Kenyan Shilling'),
  CurrencyOption('ZAR', 'South African Rand'),
  CurrencyOption('INR', 'Indian Rupee'),
  CurrencyOption('CAD', 'Canadian Dollar'),
  CurrencyOption('AUD', 'Australian Dollar'),
  CurrencyOption('JPY', 'Japanese Yen'),
];
