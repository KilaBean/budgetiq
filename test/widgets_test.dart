import 'package:budgetiq/core/error/app_error_view.dart';
import 'package:budgetiq/features/legal/presentation/pages/privacy_policy_page.dart';
import 'package:budgetiq/shared/widgets/error_view.dart';
import 'package:budgetiq/core/error/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppErrorView shows fallback and fires retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(AppErrorView(onRetry: () => retried = true));

    expect(find.text('Something went wrong'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('ErrorView renders a failure message and retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            error: const NetworkFailure('No connection'),
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('PrivacyPolicyPage renders sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyPolicyPage()));
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('What we store'), findsOneWidget);
    expect(find.textContaining('do not sell'), findsOneWidget);
  });
}
