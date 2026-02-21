import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Luxury Colors
  static const Color ivory = Color(0xFFF8F5F0);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color gold = Color(0xFFC6A75E);
  static const Color goldDark = Color(0xFFB89645);
  static const Color goldTint = Color(0xFFF3E8C8);
  static const Color primaryText = Color(0xFF1C1C1C);
  static const Color secondaryText = Color(0xFF6E6A63);
  static const Color divider = Color(0xFFE5E0D8);

  static ThemeData luxuryTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: ivory,

    colorScheme: const ColorScheme.light(
      primary: gold,
      secondary: goldDark,
      surface: pureWhite,
      onPrimary: Colors.black,
      onSurface: primaryText,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: ivory,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: primaryText),
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    ),

    cardColor: pureWhite,

    dividerColor: divider,

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryText,
        letterSpacing: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: primaryText),
      bodyMedium: TextStyle(fontSize: 14, color: secondaryText),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: gold,
        side: const BorderSide(color: gold),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: pureWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold),
      ),
      hintStyle: const TextStyle(color: secondaryText),
    ),
  );
}
