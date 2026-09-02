import 'package:budgetiq/core/config/app_config.dart';
import 'package:budgetiq/features/auth/presentation/widgets/google_logo.dart';
import 'package:budgetiq/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GoogleSignInButton renders nothing without a client ID', (
    tester,
  ) async {
    // The test binary carries no --dart-define values, so this mirrors a build
    // that never configured Google sign-in.
    expect(AppConfig.hasGoogleSignIn, isFalse);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: GoogleSignInButton())),
      ),
    );

    expect(find.text('Continue with Google'), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('AuthDivider labels the separator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AuthDivider())),
    );

    expect(find.text('or'), findsOneWidget);
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('GoogleLogo paints at the requested size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: GoogleLogo(size: 32))),
      ),
    );

    expect(tester.getSize(find.byType(GoogleLogo)), const Size(32, 32));
    expect(tester.takeException(), isNull);
  });
}
