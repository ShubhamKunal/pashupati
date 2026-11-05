import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pashupati/app/theme/theme.dart';
import 'package:pashupati/features/sos/presentation/sos_creation_screen.dart';

void main() {
  testWidgets('SOS Creation flow renders animal categories, triage mode, and CTA', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PashupatiTheme.lightTheme,
          home: const SosCreationScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Title & Stepper
    expect(find.text('Report Animal Emergency'), findsOneWidget);
    expect(find.text('Step 2 of 3 • Animal & Situation'), findsOneWidget);

    // Verify Animal Categories
    expect(find.text('1. Animal Category'), findsOneWidget);
    expect(find.text('Dog'), findsOneWidget);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('Cattle'), findsOneWidget);

    // Verify Triage Mode
    expect(find.text('2. Emergency Situation'), findsOneWidget);
    expect(find.text('Triage Mode'), findsOneWidget);

    // Verify Action Bar CTA
    expect(find.text('PUBLISH SOS ALERT NOW'), findsOneWidget);
  });
}

