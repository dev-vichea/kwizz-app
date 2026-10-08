import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'pill_border.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF4E8AF4);
  static const Color primaryDark = Color(0xFF2764D9);
  static const Color primaryLight = Color(0xFFE8F1FE);
  
  // Backgrounds
  static const Color scaffoldBg = Color(0xFFEFF4FA);
  static const Color cardBg = Colors.white;
  static const Color cardBgSoft = Color(0xFFF6F8FC);
  
  // Accent Colors
  static const Color yellow = Color(0xFFFFC833);
  static const Color yellowDark = Color(0xFFE5A800);
  static const Color yellowLight = Color(0xFFFFF7DB);
  
  static const Color teal = Color(0xFF38C1C0);
  static const Color tealLight = Color(0xFFE2F8F8);
  
  static const Color pinkGradientStart = Color(0xFFFF9EBA);
  static const Color pinkGradientEnd = Color(0xFFFF5288);
  
  static const Color blueGradientStart = Color(0xFFD6EAFF);
  static const Color blueGradientEnd = Color(0xFFB9DBFE);

  // Podium Colors
  static const Color podiumGold = Color(0xFFFEEA85);
  static const Color podiumGreen = Color(0xFFA5EDB9);
  static const Color podiumPink = Color(0xFFF9A8D4);
  
  // Neutrals & Text
  static const Color textDark = Color(0xFF131826);
  static const Color textMuted = Color(0xFF6B788E);
  static const Color textLight = Color(0xFF9CA7B8);
  static const Color blackButton = Color(0xFF10141E);
  static const Color borderLight = Color(0xFFE2E8F0);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.cardBg,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.blackButton,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
