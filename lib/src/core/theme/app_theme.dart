import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette 1 (Login & Diagnose)
  static const Color primaryGreen = Color(0xFF13EC25);
  static const Color backgroundLight = Color(0xFFF6F8F6);
  static const Color backgroundDark = Color(0xFF102212);
  static const Color textLight = Color(0xFF0D1B0F);
  static const Color textDark = Color(0xFFE0F1E2); // Updated from #E7F3E8
  static const Color mutedLight = Color(0xFF4C9A52);
  static const Color mutedDark = Color(0xFFA3B1A5);

  // Palette 2 (Settings)
  static const Color settingsPrimary = Color(0xFF4CAF50);
  static const Color settingsBackgroundLight = Color(0xFFF8F9FA);
  static const Color settingsBackgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A2C1B); // Updated from #1E1E1E
  static const Color textPrimaryLight = Color(0xFF333333);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryLight = Color(0xFF888888);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color iconBackgroundLight = Color(0xFFE8F5E9);
  static const Color iconBackgroundDark = Color(0xFF2C352D);
  
  static const Color borderLight = Color(0xFFE7F3E8);
  static const Color borderDark = Color(0xFF2A4B2C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: settingsPrimary,
        surface: surfaceLight,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textLight,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondaryLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: settingsPrimary,
        surface: surfaceDark,
        background: backgroundDark,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textDark,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textSecondaryDark,
      ),
    );
  }
}
