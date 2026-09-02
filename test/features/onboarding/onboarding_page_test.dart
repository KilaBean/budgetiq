import 'package:budgetiq/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:budgetiq/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding renders the welcome step', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currencyCodeProvider.overrideWithValue('USD')],
        child: const MaterialApp(home: OnboardingPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome to BudgetIQ'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Choose your currency'), findsOneWidget);
  });
}
