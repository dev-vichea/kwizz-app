import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kwizz/providers/auth_provider.dart';
import 'package:kwizz/screens/auth_screen.dart';

void main() {
  testWidgets('AuthScreen wide layout test (desktop/web)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('AuthScreen mobile layout test (<768px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('AuthScreen shows Forgot Password dialog on click', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(
          home: AuthScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Link'), findsOneWidget);
  });
}
