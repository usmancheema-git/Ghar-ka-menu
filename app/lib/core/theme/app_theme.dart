import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFFF5A36);
  static const Color primaryHover = Color(0xFFE04825);
  static const Color primaryLight = Color(0xFFFFF2EF);
  
  static const Color secondary = Color(0xFF4A7C59);
  static const Color secondaryHover = Color(0xFF3B6347);
  static const Color secondaryLight = Color(0xFFEEF6F1);
  
  static const Color bgApp = Color(0xFFFAF8F5);
  static const Color bgCard = Color(0xFFFFFFFF);
  
  static const Color textMain = Color(0xFF2D2A26);
  static const Color textMuted = Color(0xFF7E7873);
  
  static const Color border = Color(0xFFEBE5DF);
  static const Color accent = Color(0xFFE6A23C);
  static const Color accentLight = Color(0xFFFDF6EC);

  /// Destructive / cancelled pair. From the prototypes: the S5 delete icon and
  /// the S7 "Cancelled" badge.
  static const Color danger = Color(0xFFFF4D4F);
  static const Color dangerLight = Color(0xFFFFF1F0);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bgApp,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.bgCard,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMain,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w800),
        displayMedium: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w800),
        displaySmall: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w800),
        headlineLarge: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w800),
        headlineSmall: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.outfit(color: AppColors.textMain, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.plusJakartaSans(color: AppColors.textMain),
        bodyMedium: GoogleFonts.plusJakartaSans(color: AppColors.textMain),
        bodySmall: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
        labelLarge: GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Radius Medium
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMain,
          side: const BorderSide(color: AppColors.textMain, width: 1.5),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
          letterSpacing: 0.5,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
