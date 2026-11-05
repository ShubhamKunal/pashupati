import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pashupati/app/app.dart';

void main() {
  testWidgets('Pashupati app bootstraps cleanly and renders splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PashupatiApp(),
      ),
    );

    // Verify splash screen branding is mounted
    expect(find.text('PASHUPATI'), findsOneWidget);
    expect(find.text('STREET ANIMAL CARE & TRIAGE'), findsOneWidget);
    expect(find.text('Be the reason a life survives.'), findsOneWidget);

    // Let animation and timer settle
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
