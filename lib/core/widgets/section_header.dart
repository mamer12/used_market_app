import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A standard RTL section header row:
///   [title] on the right, [actionLabel] ("عرض الكل") on the left.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionColor = const Color(0xFF1B4FD8),
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          // Left side — "عرض الكل"
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: actionColor,
                ),
              ),
            ),
          const Spacer(),
          // Right side — title
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1713),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark variant for Mazadat (dark background).
class SectionHeaderDark extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;

  const SectionHeaderDark({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionColor = const Color(0xFFFF3D5A),
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: actionColor,
                ),
              ),
            ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
