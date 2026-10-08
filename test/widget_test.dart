import 'package:device_preview/device_preview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kwizz/main.dart';

void main() {
  testWidgets('Kwizz onboarding screen smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KwizzApp(hasSeenOnboarding: false));

    // Verify that key onboarding text elements are rendered.
    expect(find.text('Kwizz'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('DevicePreview smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      DevicePreview(
        enabled: true,
        builder: (context) => const KwizzApp(hasSeenOnboarding: false),
      ),
    );
    await tester.pump();

    // Verify app rendered inside DevicePreview
    expect(find.text('Kwizz'), findsWidgets);
  });
}

