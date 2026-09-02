import 'package:budgetiq/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptyState renders title, message and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.flag_outlined,
            title: 'No goals yet',
            message: 'Add one to get started.',
            actionLabel: 'Add goal',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No goals yet'), findsOneWidget);
    expect(find.text('Add one to get started.'), findsOneWidget);

    await tester.tap(find.text('Add goal'));
    expect(tapped, isTrue);
  });
}
