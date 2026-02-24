import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.messagesTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.inactive.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Empty state ──────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 36.sp,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        l10n.messagesEmpty,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10n.messagesEmptySub,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
