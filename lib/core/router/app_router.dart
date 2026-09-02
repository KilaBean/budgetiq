import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/goals/presentation/pages/goals_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_providers.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../shared/domain/transaction_kind.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The application router with auth-aware redirects.
///
/// Unauthenticated users are kept within the auth routes; authenticated users
/// are routed into the bottom-nav shell. Redirects re-run whenever the auth
/// session changes via [GoRouterRefreshStream].
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refresh = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges(),
  );
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      // Read the session synchronously from the repository (Supabase sets
      // currentUser before emitting the auth-change event), avoiding a race
      // with the async authState stream when the refresh fires on login.
      final loggedIn = ref.read(authRepositoryProvider).currentUser != null;
      final onboarded = ref.read(onboardingStateProvider);
      final location = state.matchedLocation;
      final onAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.signup ||
          location == AppRoutes.forgotPassword;
      final onOnboarding = location == AppRoutes.onboarding;
      final onResetPassword = location == AppRoutes.resetPassword;

      if (!loggedIn) return onAuthRoute ? null : AppRoutes.login;
      // Recovery deep link: let the user set a new password before anything
      // else, even though the recovery session counts as "logged in".
      if (onResetPassword) return null;
      if (!onboarded) return onOnboarding ? null : AppRoutes.onboarding;
      if (onAuthRoute || onOnboarding) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const AuthPage()),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => const AuthPage(initialMode: AuthMode.signUp),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ProfilePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (_, _) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.income,
                builder: (_, _) =>
                    const TransactionsPage(kind: TransactionKind.income),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (_, _) =>
                    const TransactionsPage(kind: TransactionKind.expense),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                builder: (_, _) => const BudgetsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (_, _) => const GoalsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // When a password-recovery deep link opens the app, route the user to set a
  // new password.
  ref.listen(authEventsProvider, (_, next) {
    if (next.value == AuthChangeEvent.passwordRecovery) {
      router.go(AppRoutes.resetPassword);
    }
  });

  return router;
}
