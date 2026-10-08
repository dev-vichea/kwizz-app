import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/main_nav_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  await SupabaseService().initialize();

  // Check onboarding state
  final storageService = StorageService();
  final bool hasSeenOnboarding = await storageService.isOnboardingCompleted();

  runApp(
    DevicePreview(
      enabled: kIsWeb && !kReleaseMode,
      builder: (context) => KwizzApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class KwizzApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const KwizzApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'Kwizz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        home: hasSeenOnboarding
            ? const MainNavScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}
