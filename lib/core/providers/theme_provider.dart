import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current theme mode (dark/light).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Shared palette for the Numero Shastra visual language.
class AppPalette {
  static const Color logoBlue = Color(0xFF3492FF);
  static const Color sacredGold = Color(0xFFFBBF24);

  // Semantic Blue Shades (Now all aligned to #3492FF or variations)
  static const Color primaryBlue = Color(0xFF3492FF);
  static Color get accentBlue => const Color(0xFF3492FF).withValues(alpha: 0.8);
  static Color get softBlue => const Color(0xFF3492FF).withValues(alpha: 0.1);

  static const Color darkBackground = Color(0xFF090F1F);
  static const Color darkSurface = Color(0xFF121A2F);
  static const Color darkSurfaceRaised = Color(0xFF19233D);
  static const Color darkSurfaceSoft = Color(0xFF202B47);
  static const Color darkOutline = Color(0xFF2E3A5D);
  static const Color darkText = Color(0xFFF5F7FF);
  static const Color darkMutedText = Color(0xFFB7C2DD);
  static const Color darkPrimaryContainer = Color(0xFF142B72);
  static const Color darkGoldContainer = Color(0xFF4B390A);
  static const Color darkError = Color(0xFFF87171);

  static const Color lightBackground = Color(0xFFF6F4EE);
  static const Color lightSurface = Color(0xFFFFFCF5);
  static const Color lightSurfaceRaised = Color(0xFFE8E1D2);
  static const Color lightOutline = Color(0xFFD8D1C2);
  static const Color lightText = Color(0xFF171E33);
  static const Color lightMutedText = Color(0xFF5D667D);
  static const Color lightPrimaryContainer = Color(0xFFDCE6FF);
  static const Color lightGoldContainer = Color(0xFFFFE7A6);
  static const Color lightError = Color(0xFFB91C1C);
}

/// Builds the dark theme for the Mystic Shastra aesthetic.
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.logoBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppPalette.logoBlue,
      onPrimary: Colors.white,
      primaryContainer: AppPalette.darkPrimaryContainer,
      onPrimaryContainer: AppPalette.darkText,
      secondary: AppPalette.sacredGold,
      onSecondary: const Color(0xFF1C1504),
      secondaryContainer: AppPalette.darkGoldContainer,
      onSecondaryContainer: const Color(0xFFFFF4CC),
      tertiary: const Color(0xFF8BA5FF), // Slightly lighter blue
      onTertiary: const Color(0xFF002966),
      tertiaryContainer: const Color(0xFF0044AA),
      onTertiaryContainer: const Color(0xFFD6E3FF),
      error: AppPalette.darkError,
      onError: Colors.white,
      errorContainer: const Color(0xFF4C1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkText,
      onSurfaceVariant: AppPalette.darkMutedText,
      outline: AppPalette.darkOutline,
      outlineVariant: AppPalette.darkOutline,
      inverseSurface: const Color(0xFFE8ECFA),
      onInverseSurface: const Color(0xFF151B2E),
      inversePrimary: AppPalette.logoBlue,
      surfaceContainerHighest: AppPalette.darkSurfaceSoft,
    ),
    scaffoldBackgroundColor: AppPalette.darkBackground,
    canvasColor: AppPalette.darkBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.darkOutline, width: 1.5),
      ),
      color: AppPalette.darkSurfaceRaised,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.sacredGold, width: 1.8),
      ),
      filled: true,
      fillColor: AppPalette.darkSurfaceRaised,
      labelStyle: const TextStyle(color: AppPalette.darkMutedText),
      hintStyle: const TextStyle(color: Color(0xFF7D89A7)),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.darkBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppPalette.darkText,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppPalette.darkText,
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
      backgroundColor: AppPalette.sacredGold,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.darkOutline,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppPalette.sacredGold),
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: AppPalette.sacredGold),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: AppPalette.sacredGold),
      bodyLarge: TextStyle(fontSize: 17, height: 1.6, color: AppPalette.darkText),
      bodyMedium: TextStyle(fontSize: 15.5, height: 1.55, color: AppPalette.darkMutedText),
      bodySmall: TextStyle(fontSize: 13, height: 1.5, color: AppPalette.darkMutedText),
    ),
    iconTheme: const IconThemeData(color: AppPalette.sacredGold),
  );
}

/// Builds the light theme for users who prefer a lighter look.
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.logoBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppPalette.logoBlue,
      onPrimary: Colors.white,
      primaryContainer: AppPalette.lightPrimaryContainer,
      onPrimaryContainer: AppPalette.lightText,
      secondary: const Color(0xFFB77909),
      onSecondary: Colors.white,
      secondaryContainer: AppPalette.lightGoldContainer,
      onSecondaryContainer: const Color(0xFF4D3500),
      tertiary: const Color(0xFF3492FF).withValues(alpha: 0.8),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD6E3FF),
      onTertiaryContainer: const Color(0xFF001B3D),
      error: AppPalette.lightError,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      surface: AppPalette.lightSurface,
      onSurface: AppPalette.lightText,
      onSurfaceVariant: AppPalette.lightMutedText,
      outline: AppPalette.lightOutline,
      outlineVariant: AppPalette.lightOutline,
      inverseSurface: const Color(0xFF1A223A),
      onInverseSurface: const Color(0xFFF6F7FB),
      inversePrimary: const Color(0xFF8BA5FF),
      surfaceContainerHighest: AppPalette.lightSurfaceRaised,
    ),
    scaffoldBackgroundColor: AppPalette.lightBackground,
    canvasColor: AppPalette.lightBackground,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPalette.lightOutline, width: 1.5),
      ),
      color: AppPalette.lightSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.lightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppPalette.logoBlue, width: 2),
      ),
      filled: true,
      fillColor: AppPalette.lightSurface,
      labelStyle: const TextStyle(color: AppPalette.lightMutedText),
      hintStyle: const TextStyle(color: Color(0xFF9099AD)),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppPalette.lightText,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppPalette.lightText,
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
      backgroundColor: AppPalette.logoBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.lightOutline,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 17, height: 1.6, color: AppPalette.lightText),
      bodyMedium: TextStyle(
        fontSize: 15.5,
        height: 1.55,
        color: AppPalette.lightMutedText,
      ),
      bodySmall: TextStyle(fontSize: 13, height: 1.5, color: AppPalette.lightMutedText),
    ),
  );
}
