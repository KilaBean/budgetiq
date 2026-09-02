import 'package:flutter/material.dart';

/// In-app Terms of Service. App stores require finance apps to present terms
/// before account creation; this plain-language baseline should also be hosted
/// at a public URL for store listings.
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const _sections = <(String, String)>[
    (
      'Acceptance',
      'By creating a BudgetIQ account or using this app, you agree to these '
          'Terms of Service. If you do not agree, please do not use BudgetIQ.',
    ),
    (
      'The Service',
      'BudgetIQ is a personal finance tool that helps you track income, '
          'expenses, budgets, and savings goals. We provide the app "as is" '
          'and may update features or pricing at any time with reasonable notice.',
    ),
    (
      'Your Account',
      'You are responsible for keeping your account credentials confidential. '
          'You must be at least 13 years old to create an account. You may not '
          'use the service for illegal purposes or share your account with others.',
    ),
    (
      'Your Data',
      'You own the financial data you enter. We store it securely and use it '
          'only to provide the app\'s features. We do not sell your data. See our '
          'Privacy Policy for full details on data handling.',
    ),
    (
      'Acceptable Use',
      'You agree not to attempt to access other users\' data, reverse-engineer '
          'the app, or use automated tools to scrape or stress-test the service.',
    ),
    (
      'No Financial Advice',
      'BudgetIQ provides budgeting tools and analytics but does not constitute '
          'financial, investment, tax, or legal advice. Always consult a qualified '
          'professional for decisions that affect your financial wellbeing.',
    ),
    (
      'Limitation of Liability',
      'To the fullest extent permitted by law, BudgetIQ and its developers are '
          'not liable for any indirect, incidental, or consequential damages '
          'arising from your use of the service.',
    ),
    (
      'Changes to These Terms',
      'We may update these Terms from time to time. Continued use of BudgetIQ '
          'after changes are posted constitutes acceptance of the updated Terms.',
    ),
    (
      'Contact',
      'Questions about these Terms? Reach us at support@budgetiq.app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
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
