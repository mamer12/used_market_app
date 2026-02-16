import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Reusable primary action button — "Industrial Pop" style.
///
/// Black background, white text, full-width, 56.h height.
/// Supports loading state with a circular progress indicator.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading ? _loader() : _label(),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading ? _loader() : _label(),
      ),
    );
  }

  Widget _label() => Text(
    label,
    style: GoogleFonts.cairo(
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      color: isOutlined ? AppTheme.textPrimary : AppTheme.buttonText,
    ),
  );

  Widget _loader() => SizedBox(
    width: 24.w,
    height: 24.h,
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      color: isOutlined ? AppTheme.textPrimary : AppTheme.buttonText,
    ),
  );
}
