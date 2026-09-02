import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_state_x.dart';
import '../../../auth/presentation/providers/biometric_providers.dart';
import '../../../legal/presentation/pages/privacy_policy_page.dart';
import '../../../legal/presentation/pages/terms_of_service_page.dart';
import '../../../transactions/presentation/providers/export_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _pickCurrency(BuildContext context, WidgetRef ref) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          for (final c in kSupportedCurrencies)
            ListTile(
              title: Text('${c.name} (${c.code})'),
              onTap: () => Navigator.of(context).pop(c.code),
            ),
        ],
      ),
    );
    if (selected == null) return;
    try {
      await ref.read(currentProfileProvider.notifier).setCurrency(selected);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(messageFromError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(currentUserEmailProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final isSigningOut = ref.watch(authControllerProvider).isLoading;
    final currency = ref.watch(currencyCodeProvider);
    final isExporting = ref.watch(transactionExportControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(email ?? 'Signed in'),
              subtitle: const Text('BudgetIQ account'),
            ),
          ),
          _SettingsSection(
            title: 'Preferences',
            children: [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Currency'),
                trailing: Text(
                  currency,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () => _pickCurrency(context, ref),
              ),
              _BiometricTile(),
            ],
          ),
          _SettingsSection(
            title: 'Notifications',
            children: [_NotificationTiles()],
          ),
          _SettingsSection(
            title: 'Appearance',
            children: [
              RadioGroup<ThemeMode>(
                groupValue: themeMode,
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(themeModeControllerProvider.notifier).set(mode);
                  }
                },
                child: const Column(
                  children: [
                    RadioListTile(
                      value: ThemeMode.system,
                      title: Text('System default'),
                    ),
                    RadioListTile(value: ThemeMode.light, title: Text('Light')),
                    RadioListTile(value: ThemeMode.dark, title: Text('Dark')),
                  ],
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Data',
            children: [
              ListTile(
                leading: isExporting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
                title: const Text('Export transactions'),
                subtitle: const Text('Download all data as CSV'),
                onTap: isExporting
                    ? null
                    : () => ref
                          .read(transactionExportControllerProvider.notifier)
                          .export(context),
              ),
            ],
          ),
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text('Terms of service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsOfServicePage(),
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Version'),
                trailing: Text('1.0.1 (build 2)'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: isSigningOut
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

/// A titled group of settings rendered as a single filled card, matching the
/// app's borderless card language. The header sits above the card; the rows
/// inside get clipped ink ripples on press.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Budget/goal alert toggle + daily reminder with a time picker.
class _NotificationTiles extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsControllerProvider);
    final controller = ref.read(
      notificationSettingsControllerProvider.notifier,
    );
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Budget & goal alerts'),
          subtitle: const Text('Over-budget warnings and goal milestones'),
          value: settings.alertsEnabled,
          onChanged: controller.setAlertsEnabled,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.alarm_outlined),
          title: const Text('Daily reminder'),
          subtitle: Text(
            'Remind me at ${settings.reminderTime.format(context)}',
          ),
          value: settings.reminderEnabled,
          onChanged: (v) => controller.setReminder(v),
        ),
        if (settings.reminderEnabled)
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Reminder time'),
            trailing: Text(settings.reminderTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: settings.reminderTime,
              );
              if (picked != null) {
                await controller.setReminder(true, time: picked);
              }
            },
          ),
      ],
    );
  }
}

/// Fingerprint-unlock toggle, shown only when the device supports biometrics.
/// Enabling requires a successful fingerprint check first.
class _BiometricTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = ref.watch(biometricAvailableProvider).value ?? false;
    if (!available) return const SizedBox.shrink();
    final enabled = ref.watch(biometricEnabledProvider);

    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Unlock with fingerprint'),
      subtitle: const Text('Require fingerprint when opening the app'),
      value: enabled,
      onChanged: (value) async {
        final notifier = ref.read(biometricEnabledProvider.notifier);
        if (value) {
          final ok = await ref
              .read(biometricGateProvider.notifier)
              .authenticate();
          if (ok) await notifier.set(true);
        } else {
          await notifier.set(false);
        }
      },
    );
  }
}
