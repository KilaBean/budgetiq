import 'package:flutter/material.dart';

/// In-app privacy policy. App stores require finance apps to disclose data
/// handling; this is a clear, plain-language baseline to review and also host
/// at a public URL for store listings.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = <(String, String)>[
    (
      'Overview',
      'BudgetIQ helps you track income, expenses, budgets and savings goals. '
          'This policy explains what we store and how it is used.',
    ),
    (
      'What we store',
      'Your account email (for sign-in) and the financial data you enter — '
          'income, expenses, categories, budgets and goals. We do not collect '
          'your contacts, location, or advertising identifiers.',
    ),
    (
      'Where it is stored',
      'Data is saved locally on your device and synced to your private cloud '
          'account (Supabase). Row-level security ensures only you can read or '
          'write your data.',
    ),
    (
      'How it is used',
      'Your data is used solely to provide the app\'s features — dashboards, '
          'analytics and rule-based insights computed on your own data. We do '
          'not sell your data or use it for advertising.',
    ),
    (
      'Offline use',
      'The app works offline. Changes are stored on your device and synced to '
          'the cloud when you reconnect.',
    ),
    (
      'Your choices',
      'You can edit or delete your entries at any time. To delete your account '
          'and associated data, contact support and we will remove it.',
    ),
    (
      'Contact',
      'Questions about this policy? Reach us at support@budgetiq.app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Last updated: June 2026',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (final (title, body) in _sections) ...[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
