import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Madhmoon — Institution of Trust" Design System v2
/// "حضارة حديثة" — Modern Civilisation aesthetic.
///
/// Art direction: Iraqi senior creative perspective.
/// • Warm parchment surfaces (#F7F5F0) — aged market paper, not cold white
/// • Tigris Deep (#0D1F3C) — Abbasid authority, heavier than standard navy
/// • Dinar Amber (#C9930A) — real Iraqi dinar under light, not pageant-yellow
/// • Emerald Marsh (#059669) — the southern marshes, richer than flat green
/// • Warm near-black text (#1C1713) — ink on manuscript
/// • 20r cards, stadium buttons, 28r bottom sheets
/// • Tajawal font everywhere — Arabic soul, modern body
class AppTheme {
  AppTheme._();

  // ── Brand Palette ────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF0D1F3C); // Tigris Deep
  static const Color primaryDark    = Color(0xFF060F1E); // Abyssal (gradient end)
  static const Color primaryMid     = Color(0xFF1A3660); // Mid gradient step
  static const Color tigrisBlue     = Color(0xFF0D1F3C); // Alias
  static const Color dinarGold      = Color(0xFFC9930A); // Dinar Amber
  static const Color dinarGoldLight = Color(0xFFFFF0C4); // Soft gold surface
  static const Color emeraldGreen   = Color(0xFF059669); // Marshland Emerald
  static const Color secondary      = Color(0xFFC9930A); // Alias → Dinar Amber
  static const Color background     = Color(0xFFF7F5F0); // Warm parchment
  static const Color surface        = Color(0xFFEDE8E0); // Warm card grey
  static const Color surfaceAlt     = Color(0xFFFEFCF8); // Warm elevated white
  static const Color textPrimary    = Color(0xFF1C1713); // Warm near-black
  static const Color textSecondary  = Color(0xFF6B5E52); // Warm grey
  static const Color textTertiary   = Color(0xFFA89585); // Warm pale
  static const Color divider        = Color(0xFFEDE6DC); // Warm rule
  static const Color buttonBg       = Color(0xFF0D1F3C); // Tigris Deep buttons
  static const Color buttonText     = Color(0xFFFFFFFF); // White on navy
  static const Color inactive       = Color(0xFFC4B8AD); // Warm muted
  static const Color error          = Color(0xFFDC2626); // Red 600
  static const Color success        = Color(0xFF059669); // Emerald Marsh
  static const Color liveBadge      = Color(0xFFFF1744); // Pulsing red
  static const Color accentRed      = Color(0xFFFF3B30); // Live badge
  static const Color accentYellow   = Color(0xFFC9930A); // Dinar Amber alias

  // ── Shimmer — warm toned ────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFEDE8E0);
  static const Color shimmerHighlight = Color(0xFFE4DDD4);

  // ── Mini-App Brand Colours ───────────────────────────────────────────────
  static const Color matajirBlue           = Color(0xFF1B4FD8);
  static const Color matajirBlueSurface    = Color(0xFFEBF0FE);
  static const Color ballaPurple           = Color(0xFF7C3AED);
  static const Color ballaPurpleSurface    = Color(0xFFEDE7F6);
  static const Color mustamalOrange        = Color(0xFFEA580C);
  static const Color mustamalOrangeSurface = Color(0xFFFFF3E0);
  static const Color mazadGreen            = Color(0xFFFF3D5A);
  static const Color mazadGreenSurface     = Color(0xFFFFF0F2);

  // ── Spacing (8-point grid) ───────────────────────────────────────────────
  static double get spacingXs => 4.w;
  static double get spacingSm => 8.w;
  static double get spacingMd => 16.w;
  static double get spacingLg => 24.w;
  static double get spacingXl => 32.w;

  // ── Border Radius ────────────────────────────────────────────────────────
  static double get radiusSm   => 8.r;
  static double get radiusMd   => 12.r;
  static double get radiusLg   => 20.r;  // cards — 16→20 more welcoming
  static double get radiusXl   => 28.r;  // bottom sheets
  static double get radiusFull => 999.r; // pills

  // ── Card Decoration ──────────────────────────────────────────────────────
  /// Standard card: 20r, 1px warm border, hairline shadow
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceAlt,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: const Color(0xFFD8D0C4)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1C1713).withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Elevated card: richer shadow for floating elements
  static BoxDecoration get cardElevatedDecoration => BoxDecoration(
    color: surfaceAlt,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: const Color(0xFFD8D0C4)),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1C1713).withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: const Color(0xFF1C1713).withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // ── Typography ───────────────────────────────────────────────────────────
  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.tajawal(
      fontSize: 32.sp, fontWeight: FontWeight.w800,
      color: textPrimary, height: 1.2,
    ),
    displayMedium: GoogleFonts.tajawal(
      fontSize: 28.sp, fontWeight: FontWeight.w800,
      color: textPrimary, height: 1.2,
    ),
    headlineLarge: GoogleFonts.tajawal(
      fontSize: 24.sp, fontWeight: FontWeight.w700,
      color: textPrimary, height: 1.25,
    ),
    headlineMedium: GoogleFonts.tajawal(
      fontSize: 20.sp, fontWeight: FontWeight.w700,
      color: textPrimary, height: 1.3,
    ),
    titleLarge: GoogleFonts.tajawal(
      fontSize: 18.sp, fontWeight: FontWeight.w600, color: textPrimary,
    ),
    titleMedium: GoogleFonts.tajawal(
      fontSize: 16.sp, fontWeight: FontWeight.w600, color: textPrimary,
    ),
    bodyLarge: GoogleFonts.tajawal(
      fontSize: 16.sp, fontWeight: FontWeight.w400,
      color: textSecondary, height: 1.55,
    ),
    bodyMedium: GoogleFonts.tajawal(
      fontSize: 14.sp, fontWeight: FontWeight.w400,
      color: textSecondary, height: 1.55,
    ),
    bodySmall: GoogleFonts.tajawal(
      fontSize: 12.sp, fontWeight: FontWeight.w400,
      color: textTertiary, height: 1.4,
    ),
    labelLarge: GoogleFonts.tajawal(
      fontSize: 16.sp, fontWeight: FontWeight.w700, color: buttonText,
    ),
    labelMedium: GoogleFonts.tajawal(
      fontSize: 12.sp, fontWeight: FontWeight.w600, color: textSecondary,
    ),
    labelSmall: GoogleFonts.tajawal(
      fontSize: 10.sp, fontWeight: FontWeight.w600, color: textTertiary,
    ),
  );

  // ── Price Style ──────────────────────────────────────────────────────────
  static TextStyle priceStyle({double? fontSize, Color? color}) =>
      GoogleFonts.tajawal(
        fontSize: fontSize ?? 20.sp,
        fontWeight: FontWeight.w800,
        color: color ?? textPrimary,
        height: 1.2,
      );

  static TextStyle priceSuffixStyle({Color? color}) => GoogleFonts.tajawal(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: color ?? textTertiary,
  );

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary:     primary,
      secondary:   secondary,
      tertiary:    emeraldGreen,
      surface:     surface,
      error:       error,
      onPrimary:   buttonText,
      onSecondary: textPrimary,
      onTertiary:  buttonText,
      onSurface:   textPrimary,
      onError:     buttonText,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor:        primary,
      foregroundColor:        Colors.white,
      elevation:              0,
      scrolledUnderElevation: 0,
      centerTitle:            true,
      iconTheme:              const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: dinarGold,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: buttonText,
        minimumSize:     Size(double.infinity, 56.h),
        elevation:       0,
        shape:           const StadiumBorder(),
        textStyle: GoogleFonts.tajawal(
          fontSize: 16.sp, fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        minimumSize:     Size(double.infinity, 56.h),
        side:            const BorderSide(color: divider, width: 1.5),
        shape:           const StadiumBorder(),
        textStyle: GoogleFonts.tajawal(
          fontSize: 16.sp, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.tajawal(
          fontSize: 14.sp, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:         true,
      fillColor:      surfaceAlt,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide:   const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide:   const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide:   const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide:   const BorderSide(color: error),
      ),
      hintStyle: GoogleFonts.tajawal(fontSize: 14.sp, color: textTertiary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor:   primary.withValues(alpha: 0.12),
      labelStyle: GoogleFonts.tajawal(
        fontSize: 13.sp, fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      side:  const BorderSide(color: divider),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceAlt,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color:     divider,
      thickness: 1,
      space:     0,
    ),
  );
}
