import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/biometric_providers.dart';

/// Wraps the app and, when a session exists and fingerprint unlock is enabled,
/// blocks the UI behind a [_BiometricLockScreen] until the user authenticates.
/// Re-locks when the app returns from the background.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-lock when leaving the foreground so returning requires fingerprint.
    if (state == AppLifecycleState.paused &&
        ref.read(biometricEnabledProvider)) {
      ref.read(biometricGateProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = ref.watch(authStateProvider).value != null;
    final enabled = ref.watch(biometricEnabledProvider);
    final unlocked = ref.watch(biometricGateProvider);

    final locked = loggedIn && enabled && !unlocked;
    return Stack(
      children: [widget.child, if (locked) const _BiometricLockScreen()],
    );
  }
}

class _BiometricLockScreen extends ConsumerStatefulWidget {
  const _BiometricLockScreen();

  @override
  ConsumerState<_BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<_BiometricLockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  Future<void> _prompt() =>
      ref.read(biometricGateProvider.notifier).authenticate();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'BudgetIQ is locked',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock with your fingerprint to continue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _prompt,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
