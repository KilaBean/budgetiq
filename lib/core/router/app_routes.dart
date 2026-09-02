/// Centralized route paths and names used across the app.
class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String onboarding = '/onboarding';

  static const String dashboard = '/dashboard';

  /// Income and expenses share one tab; the kind is chosen in-page. The old
  /// per-kind paths still resolve so existing links keep working.
  static const String transactions = '/transactions';
  static const String income = '/income';
  static const String expenses = '/expenses';
  static const String budgets = '/budgets';
  static const String goals = '/goals';
  static const String insights = '/insights';
  static const String profile = '/profile';
}
