import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current theme mode (dark/light).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Builds the dark theme for the Mystic Shastra aesthetic.
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),       // Lighter indigo for dark bg readability
      secondary: const Color(0xFFFBBF24),     // Warm amber gold
      surface: const Color(0xFF0F172A),       // Deep navy-black
      onSurface: const Color(0xFFF1F5F9),     // Near-white for text
      onSurfaceVariant: const Color(0xFFCBD5E1), // Lighter slate for body text
      surfaceContainerHighest: const Color(0xFF1E293B),
      outlineVariant: const Color(0xFF334155),
      error: const Color(0xFFF87171),         // Lighter red for dark mode
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155), width: 1.5),
      ),
      color: const Color(0xFF1E293B),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      hintStyle: const TextStyle(color: Color(0xFF475569)),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF1F5F9),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Color(0xFFF1F5F9),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFFFBBF24),
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 17, height: 1.6),
      bodyMedium: TextStyle(fontSize: 15.5, height: 1.55),
      bodySmall: TextStyle(fontSize: 13, height: 1.5),
    ),
  );
}

/// Builds the light theme for users who prefer a lighter look.
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
      primary: const Color(0xFF4F46E5),       // Deep indigo
      secondary: const Color(0xFFD97706),     // Warm amber
      surface: const Color(0xFFF8FAFC),       // Softened background (lighter than slate, darker than pure white)
      onSurface: const Color(0xFF0F172A),     // Darker navy for better contrast
      onSurfaceVariant: const Color(0xFF334155), // Darker slate for body/secondary text
      surfaceContainerHighest: const Color(0xFFF1F5F9),
      outlineVariant: const Color(0xFFE2E8F0),
      error: const Color(0xFFDC2626),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Color(0xFF475569)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF0F172A),
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Color(0xFF0F172A),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 17, height: 1.6, color: Color(0xFF0F172A)),
      bodyMedium: TextStyle(fontSize: 15.5, height: 1.55, color: Color(0xFF334155)),
      bodySmall: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF475569)),
    ),
  );
}
