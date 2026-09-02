import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/onboarding_providers.dart';

/// First-run onboarding: a brief welcome and a one-time currency choice, then
/// the user lands on the dashboard. A single scrollable screen with a fixed
/// action button.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late String _currency = ref.read(currencyCodeProvider);
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref.read(currentProfileProvider.notifier).setCurrency(_currency);
      await ref.read(onboardingStateProvider.notifier).complete();
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(messageFromError(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to BudgetIQ',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track income and expenses, set budgets and goals, and get '
                    'clear, explainable insights — even offline.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Choose your currency',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'All amounts use this currency. You can change it later in '
                    'your profile.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RadioGroup<String>(
                    groupValue: _currency,
                    onChanged: (v) =>
                        setState(() => _currency = v ?? _currency),
                    child: Column(
                      children: [
                        for (final c in kSupportedCurrencies)
                          RadioListTile<String>(
                            value: c.code,
                            contentPadding: EdgeInsets.zero,
                            title: Text('${c.name} (${c.code})'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _saving ? null : _finish,
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Get started'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
