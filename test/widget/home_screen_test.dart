import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pashupati/app/theme/theme.dart';
import 'package:pashupati/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('Home screen renders Stitch elements, emergency button, and live feed', (WidgetTester tester) async {
    // Set a phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: PashupatiTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Brand Header
    expect(find.text('Pashupati'), findsOneWidget);
    expect(find.text('BLR DISPATCH LIVE'), findsOneWidget);

    // Verify Emergency Hero Section
    expect(find.text('EMERGENCY DISPATCH'), findsOneWidget);
    expect(find.text('An animal needs help?'), findsOneWidget);
    expect(find.text('REPORT ANIMAL SOS'), findsOneWidget);

    // Verify Section Headers
    expect(find.text('Critical Incidents'), findsOneWidget);

    // Scroll down to reveal Emergency Trauma Centers
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Emergency Trauma Centers'), findsOneWidget);
  });
}
