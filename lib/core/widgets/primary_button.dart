import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Reusable primary action button — "Iraqi Bazaar Modernism" style.
///
/// Stadium-shaped, full-width, 56.h height.
/// [variant] controls colour: primary (yellow), dark (black), outlined.
/// Supports loading state and haptic feedback.
enum ButtonVariant { primary, dark, outlined }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final ButtonVariant variant;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  ButtonVariant get _effectiveVariant =>
      isOutlined ? ButtonVariant.outlined : variant;

  @override
  Widget build(BuildContext context) {
    final effective = _effectiveVariant;

    if (effective == ButtonVariant.outlined) {
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: OutlinedButton(
          onPressed: isLoading ? null : _handleTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.divider, width: 1.5),
            shape: const StadiumBorder(),
          ),
          child: isLoading ? _loader(AppTheme.textPrimary) : _content(effective),
        ),
      );
    }

    final bg = effective == ButtonVariant.dark
        ? AppTheme.buttonBg
        : AppTheme.primary;
    // Both primary and dark variants use white text on Tigris Deep
    const fg = AppTheme.buttonText;

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: isLoading ? _loader(fg) : _content(effective),
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  Widget _content(ButtonVariant v) {
    final color = v == ButtonVariant.outlined
        ? AppTheme.textPrimary
        : AppTheme.buttonText; // white on both primary & dark

    final label = Text(
      this.label,
      style: GoogleFonts.tajawal(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon!, SizedBox(width: 8.w), label],
      );
    }
    return label;
  }

  Widget _loader(Color color) => SizedBox(
    width: 24.w,
    height: 24.h,
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      color: color,
    ),
  );
}
