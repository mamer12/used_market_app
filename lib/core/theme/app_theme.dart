import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Industrial Pop" Design System — High Contrast, Bold, Minimalist.
class AppTheme {
  AppTheme._();

  // ── Brand Colors ─────────────────────────────────────
  static const Color primary = Color(0xFFFFB703); // Vivid Yolk Yellow
  static const Color secondary = Color(0xFFFB8500); // Deep Orange
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFF8F9FA); // Light Grey (cards)
  static const Color textPrimary = Color(0xFF000000); // Pure Black
  static const Color textSecondary = Color(0xFF4A4A4A); // Dark Grey (body)
  static const Color buttonBg = Color(0xFF000000); // Black buttons
  static const Color buttonText = Color(0xFFFFFFFF); // White text on buttons
  static const Color inactive = Color(0xFFBDBDBD); // Inactive/grey elements
  static const Color error = Color(0xFFE53935); // Error red
  static const Color liveBadge = Color(0xFFFF1744); // Live badge red

  // ── Typography ───────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.cairo(
      fontSize: 32.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    displayMedium: GoogleFonts.cairo(
      fontSize: 28.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    headlineLarge: GoogleFonts.cairo(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: 18.sp,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14.sp,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: textSecondary,
    ),
    labelLarge: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: buttonText,
    ),
    labelSmall: GoogleFonts.cairo(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: textSecondary,
    ),
  );

  // ── Light Theme ──────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      onPrimary: textPrimary,
      onSecondary: buttonText,
      onSurface: textPrimary,
      onError: buttonText,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonBg,
        foregroundColor: buttonText,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize: Size(double.infinity, 56.h),
        side: const BorderSide(color: textPrimary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: inactive),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: inactive),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: textPrimary, width: 2),
      ),
      hintStyle: GoogleFonts.cairo(fontSize: 14.sp, color: inactive),
    ),
  );
}
