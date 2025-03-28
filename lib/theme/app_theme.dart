import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern color palette for 2025
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _secondaryBlue = Color(0xFF3B82F6);
  static const Color _accentGreen = Color(0xFF10B981);
  static const Color _accentRed = Color(0xFFEF4444);
  static const Color _backgroundLight = Color(0xFFF8FAFC);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _backgroundDark = Color(0xFF0F172A);
  static const Color _surfaceDark = Color(0xFF1E293B);
  static const Color _textLight = Color(0xFF1E293B);
  static const Color _textDark = Color(0xFFF8FAFC);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _primaryBlue,
        onPrimary: Colors.white,
        secondary: _secondaryBlue,
        onSecondary: Colors.white,
        error: _accentRed,
        onError: Colors.white,
        background: _backgroundLight,
        onBackground: _textLight,
        surface: _surfaceLight,
        onSurface: _textLight,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceLight,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textLight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        elevation: 0,
        indicatorColor: _primaryBlue.withAlpha(24),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _primaryBlue,
        onPrimary: Colors.white,
        secondary: _secondaryBlue,
        onSecondary: Colors.white,
        error: _accentRed,
        onError: Colors.white,
        background: _backgroundDark,
        onBackground: _textDark,
        surface: _surfaceDark,
        onSurface: _textDark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _surfaceDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        elevation: 0,
        indicatorColor: _primaryBlue.withAlpha(24),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Getter methods for chart colors
  static List<Color> get chartColors => [
        _primaryBlue,
        _secondaryBlue,
        _accentGreen,
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF8B5CF6), // Purple
        const Color(0xFFEC4899), // Pink
      ];
} 