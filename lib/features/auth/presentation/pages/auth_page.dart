import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/haptics.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/validation/auth_validators.dart';
import '../../../legal/presentation/pages/privacy_policy_page.dart';
import '../providers/auth_controller.dart';
import '../widgets/brand_header.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/password_strength_bar.dart';

enum AuthMode { signIn, signUp }

/// Unified sign-in / sign-up screen with a segmented toggle, branded header,
/// inline + banner errors, password strength, and a post-sign-up confirmation
/// state.
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late AuthMode _mode = widget.initialMode;
  bool _obscure = true;
  String _password = '';
  String? _pendingEmail; // set when sign-up needs email confirmation

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _isSignUp => _mode == AuthMode.signUp;

  void _switchMode(AuthMode mode) {
    if (mode == _mode) return;
    Haptics.selection();
    setState(() {
      _mode = mode;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    Haptics.light();
    final controller = ref.read(authControllerProvider.notifier);
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isSignUp) {
      final user = await controller.signUp(email: email, password: password);
      // Confirmation required → show the check-email panel. If a session was
      // created (confirmation disabled), the router redirect takes over.
      if (user != null && !user.emailConfirmed && mounted) {
        setState(() => _pendingEmail = email.trim());
      }
    } else {
      await controller.signIn(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(authControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _pendingEmail != null
                  ? _ConfirmEmailPanel(
                      email: _pendingEmail!,
                      onBack: () => setState(() {
                        _pendingEmail = null;
                        _switchMode(AuthMode.signIn);
                      }),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BrandHeader(),
                        const SizedBox(height: 28),
                        SegmentedButton<AuthMode>(
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            side: const WidgetStatePropertyAll(BorderSide.none),
                            backgroundColor: WidgetStateProperty.resolveWith(
                              (states) => states.contains(WidgetState.selected)
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: AuthMode.signIn,
                              label: Text('Sign in'),
                            ),
                            ButtonSegment(
                              value: AuthMode.signUp,
                              label: Text('Sign up'),
                            ),
                          ],
                          selected: {_mode},
                          onSelectionChanged: (s) => _switchMode(s.first),
                        ),
                        const SizedBox(height: 24),
                        if (state.hasError && !isLoading)
                          _ErrorBanner(message: messageFromError(state.error!)),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: AuthValidators.email,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                autofillHints: [
                                  _isSignUp
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                textInputAction: _isSignUp
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                onChanged: (v) => setState(() => _password = v),
                                onFieldSubmitted: (_) =>
                                    _isSignUp ? null : _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    tooltip: _obscure
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: _isSignUp
                                    ? AuthValidators.password
                                    : (v) => (v ?? '').isEmpty
                                          ? 'Password is required.'
                                          : null,
                              ),
                              if (_isSignUp)
                                PasswordStrengthBar(password: _password),
                              if (_isSignUp) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscure,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm password',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  validator: (v) =>
                                      AuthValidators.confirmPassword(
                                        v,
                                        _passwordController.text,
                                      ),
                                ),
                              ],
                              if (!_isSignUp)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => context.push(
                                            AppRoutes.forgotPassword,
                                          ),
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              FilledButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        _isSignUp
                                            ? 'Create account'
                                            : 'Sign in',
                                      ),
                              ),
                            ],
                          ),
                        ),
                        if (AppConfig.hasGoogleSignIn) ...[
                          const SizedBox(height: 20),
                          const AuthDivider(),
                          const SizedBox(height: 16),
                          const GoogleSignInButton(),
                        ],
                        // Google is a sign-up path in either mode, so the
                        // consent line shows whenever it is offered.
                        if (_isSignUp || AppConfig.hasGoogleSignIn) ...[
                          const SizedBox(height: 16),
                          _PrivacyLine(),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp
                              ? 'Manage your money with clear, offline-first '
                                    'tracking.'
                              : 'Welcome back — sign in to continue.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'By continuing you agree to our ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()),
          ),
          child: Text(
            'Privacy Policy',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmEmailPanel extends ConsumerWidget {
  const _ConfirmEmailPanel({required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mark_email_unread_outlined,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Confirm your email',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a confirmation link to $email. Tap it to activate your '
          'account, then sign in.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: isLoading
              ? null
              : () async {
                  final ok = await ref
                      .read(authControllerProvider.notifier)
                      .resendConfirmation(email);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Confirmation email sent.')),
                    );
                  }
                },
          icon: const Icon(Icons.refresh),
          label: const Text('Resend email'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onBack, child: const Text('Back to sign in')),
      ],
    );
  }
}
