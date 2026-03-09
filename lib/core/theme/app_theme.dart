import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Iraqi Bazaar Modernism" Design System
/// Warm, Bold, Trust-Forward — Arabic-first RTL marketplace.
///
/// Key principles:
/// • Cairo font everywhere (Arabic-optimised, 800 for prices, 600 headers, 400 body)
/// • Warm off-white surface (#FAFAF7) — not sterile white
/// • 8-point grid, rounded-2xl cards (16r), stadium buttons
/// • Per-sooq accent colours used only in their own context
/// • Haptic feedback on every interactive touch
class AppTheme {
  AppTheme._();

  // ── Brand Palette ────────────────────────────────────
  static const Color primary = Color(0xFFFFB703); // Vivid Yolk Yellow
  static const Color secondary = Color(0xFFFB8500); // Deep Amber
  static const Color background = Color(0xFFFAFAF7); // Warm Off-White
  static const Color surface = Color(0xFFF5F0E8); // Warm Sand (cards)
  static const Color surfaceAlt = Color(0xFFFFFFFF); // Pure White (elevated)
  static const Color textPrimary = Color(0xFF1A1A1A); // Near-Black
  static const Color textSecondary = Color(0xFF6B7280); // Cool Grey 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Cool Grey 400
  static const Color divider = Color(0xFFE8E0D0); // Warm divider
  static const Color buttonBg = Color(0xFF1A1A1A); // Near-Black buttons
  static const Color buttonText = Color(0xFFFFFFFF); // White on dark
  static const Color inactive = Color(0xFFBDBDBD); // Grey elements
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color liveBadge = Color(0xFFFF1744); // Pulsing red
  static const Color accentRed = Color(0xFFFF3B30); // Live badge accent
  static const Color accentYellow = Color(0xFFFFD700); // Gold / exclusive badge

  // ── Shimmer Placeholder Colours ──────────────────────
  static const Color shimmerBase = Color(0xFFF5F0E8);
  static const Color shimmerHighlight = Color(0xFFE8E0D0);

  // ── Mini-App Brand Colours ───────────────────────────
  /// Matajir — trustworthy blue
  static const Color matajirBlue = Color(0xFF1565C0);
  static const Color matajirBlueSurface = Color(0xFFE3F2FD);

  /// Balla — deep purple
  static const Color ballaPurple = Color(0xFF7C4DFF);
  static const Color ballaPurpleSurface = Color(0xFFEDE7F6);

  /// Mustamal — warm orange
  static const Color mustamalOrange = Color(0xFFE65100);
  static const Color mustamalOrangeSurface = Color(0xFFFFF3E0);

  /// Mazad — Stitch vibrant green
  static const Color mazadGreen = Color(0xFF13EC6A);
  static const Color mazadGreenSurface = Color(0xFFE7FDF0);

  // ── Spacing Constants (8-point grid) ─────────────────
  static double get spacingXs => 4.w;
  static double get spacingSm => 8.w;
  static double get spacingMd => 16.w;
  static double get spacingLg => 24.w;
  static double get spacingXl => 32.w;

  // ── Border Radius ────────────────────────────────────
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r; // rounded-2xl for cards
  static double get radiusXl => 24.r;
  static double get radiusFull => 999.r; // stadiums & pills

  // ── Card Decoration ──────────────────────────────────
  /// Standard card: rounded-2xl, 1px warm border, no shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceAlt,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
  );

  /// Elevated card: slight shadow for floating elements
  static BoxDecoration get cardElevatedDecoration => BoxDecoration(
    color: surfaceAlt,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ── Typography ───────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    // Display — extra-bold hero text
    displayLarge: GoogleFonts.cairo(
      fontSize: 32.sp,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.cairo(
      fontSize: 28.sp,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      height: 1.2,
    ),
    // Headlines — bold section headers
    headlineLarge: GoogleFonts.cairo(
      fontSize: 24.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      height: 1.3,
    ),
    // Titles — semi-bold
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
    // Body — regular weight
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      color: textTertiary,
      height: 1.4,
    ),
    // Labels — bold for buttons and tags
    labelLarge: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: buttonText,
    ),
    labelMedium: GoogleFonts.cairo(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: textSecondary,
    ),
    labelSmall: GoogleFonts.cairo(
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
      color: textTertiary,
    ),
  );

  // ── Price Text Style (always bold, always large) ─────
  static TextStyle priceStyle({
    double? fontSize,
    Color? color,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize ?? 20.sp,
        fontWeight: FontWeight.w800,
        color: color ?? textPrimary,
        height: 1.2,
      );

  /// Small "د.ع" suffix style
  static TextStyle priceSuffixStyle({Color? color}) => GoogleFonts.cairo(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color ?? textTertiary,
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
    // ── Stadium Buttons ──────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        minimumSize: Size(double.infinity, 56.h),
        elevation: 0,
        shape: const StadiumBorder(),
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
        side: const BorderSide(color: divider, width: 1.5),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.cairo(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    // ── Warm Input Fields ────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: error),
      ),
      hintStyle: GoogleFonts.cairo(fontSize: 14.sp, color: textTertiary),
    ),
    // ── Chips ────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      side: const BorderSide(color: divider),
    ),
    // ── Bottom Sheet ─────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),
    // ── Dividers ─────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 0,
    ),
  );
}
