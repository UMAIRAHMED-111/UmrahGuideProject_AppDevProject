import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF3F5C3D); // dark green
  static const Color accentBeige = Color(0xFFD6C3A3); // beige

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: primaryGreen,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      useMaterial3: true,
    );
  }
}
