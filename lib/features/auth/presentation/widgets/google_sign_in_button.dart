import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/haptics.dart';
import '../providers/auth_controller.dart';
import 'google_logo.dart';

/// "Continue with Google" button.
///
/// One button covers both sign-in and sign-up: Supabase provisions the account
/// on first use of a Google identity, so the label stays neutral. Renders
/// nothing when the build has no Google client ID configured, so an
/// unconfigured build never shows an option that cannot work.
class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.hasGoogleSignIn) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () {
              Haptics.light();
              ref.read(authControllerProvider.notifier).signInWithGoogle();
            },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        foregroundColor: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The mark is painted directly rather than passed as an `icon`, so
          // it keeps its brand colours instead of being tinted by the
          // button's disabled foreground colour.
          const GoogleLogo(),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal rule with a centered "or", separating the password form from
/// the social provider.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final line = Expanded(
      child: Divider(color: theme.colorScheme.outlineVariant, height: 1),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
