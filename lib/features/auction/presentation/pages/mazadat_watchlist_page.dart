import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// المراقبة — Auction Watchlist page.
///
/// Shows auctions the user is watching/tracking. Uses Stitch Screen 8
/// design language with green (#13EC6A) accent.
class MazadatWatchlistPage extends StatelessWidget {
  const MazadatWatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────
          SliverAppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              'المراقبة',
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                },
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: AppTheme.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),

          // ── Stats Row ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Row(
                children: [
                  const _StatChip(
                    icon: Icons.visibility_rounded,
                    label: 'مراقَبة',
                    count: '٠',
                    color: AppTheme.mazadGreen,
                  ),
                  SizedBox(width: 8.w),
                  const _StatChip(
                    icon: Icons.notifications_active_rounded,
                    label: 'تنبيهات',
                    count: '٠',
                    color: Color(0xFF3B82F6), // blue
                  ),
                  SizedBox(width: 8.w),
                  const _StatChip(
                    icon: Icons.timer_rounded,
                    label: 'تنتهي قريباً',
                    count: '٠',
                    color: Color(0xFFF59E0B), // amber
                  ),
                ],
              ),
            ),
          ),

          // ── Empty State ────────────────────────────
          SliverFillRemaining(
            child: _EmptyWatchlist(),
          ),
        ],
      ),
    );
  }
}

// ── Stat Chip ───────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              count,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Watchlist ─────────────────────────────────────────────────────────
class _EmptyWatchlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.visibility_off_rounded,
                size: 42.sp,
                color: AppTheme.mazadGreen.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد مراقبات نشطة',
              style: GoogleFonts.cairo(
                color: AppTheme.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'أضف مزادات إلى قائمة المراقبة\nليصلك تنبيه قبل انتهاء المزاد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: AppTheme.textTertiary,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 28.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mazadGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded,
                        color: AppTheme.textPrimary, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'تصفح المزادات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
