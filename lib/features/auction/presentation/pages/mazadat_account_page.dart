import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// حسابي — Mazadat Account/Profile page.
///
/// Stitch Screen 7 — الملف الشخصي
/// Dark wallet card, verified badge, menu rows with icon-left chevrons.
class MazadatAccountPage extends StatelessWidget {
  const MazadatAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Bar (Stitch: "الملف الشخصي" + settings gear) ───────────
          SliverAppBar(
            backgroundColor: AppTheme.surfaceAlt,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(
              'الملف الشخصي',
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  margin: EdgeInsets.only(left: 16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    size: 22.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          // ── Profile Card ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    // Avatar with verified badge
                    Stack(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.mazadGreen.withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Icon(
                              Icons.person_rounded,
                              size: 36.sp,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: AppTheme.mazadGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.surfaceAlt,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 12.sp,
                              color: const Color(0xFF121212),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أحمد محمد',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.mazadGreenSurface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 14.sp,
                                color: const Color(0xFF16A34A),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'عضو موثق',
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Wallet Card (Stitch: dark gradient) ────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF0F4025), // Stitch dark-green
                      Color(0xFF121212), // Stitch industrial-black
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF121212).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Glow circle
                    Positioned(
                      right: -40.w,
                      top: -40.h,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.mazadGreen.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيد المحفظة',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '٤٥٠,٠٠٠',
                              style: GoogleFonts.cairo(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'د.ع',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.mazadGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: _WalletButton(
                                icon: Icons.add_circle_rounded,
                                label: 'إيداع رصيد',
                                backgroundColor: AppTheme.mazadGreen,
                                foregroundColor: const Color(0xFF121212),
                                onTap: () {},
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _WalletButton(
                                icon:
                                    Icons.account_balance_wallet_rounded,
                                label: 'سحب الرصيد',
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                foregroundColor: Colors.white,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Menu Rows ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _MenuRow(
                      icon: Icons.gavel_rounded,
                      label: 'مزاداتي النشطة',
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF2563EB),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/mazadat/bids');
                      },
                    ),
                    _MenuDivider(),
                    _MenuRow(
                      icon: Icons.history_rounded,
                      label: 'سجل المزايدات',
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      onTap: () => HapticFeedback.lightImpact(),
                    ),
                    _MenuDivider(),
                    _MenuRow(
                      icon: Icons.location_on_rounded,
                      label: 'عناوين الشحن',
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => HapticFeedback.lightImpact(),
                    ),
                    _MenuDivider(),
                    _MenuRow(
                      icon: Icons.notifications_rounded,
                      label: 'الإشعارات',
                      iconBg: AppTheme.surface,
                      iconColor: AppTheme.textSecondary,
                      onTap: () => HapticFeedback.lightImpact(),
                    ),
                    _MenuDivider(),
                    _MenuRow(
                      icon: Icons.logout_rounded,
                      label: 'تسجيل الخروج',
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFEF4444),
                      labelColor: const Color(0xFFEF4444),
                      showChevron: false,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Version footer ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 120.h),
              child: Center(
                child: Text(
                  'Luqta Mazadat v2.4.0',
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wallet Button ───────────────────────────────────────────────────────────
class _WalletButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _WalletButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foregroundColor, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Row ────────────────────────────────────────────────────────────────
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final Color? labelColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    this.labelColor,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: labelColor ?? AppTheme.textSecondary,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_left_rounded,
                color: AppTheme.inactive,
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Divider ────────────────────────────────────────────────────────────
class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 72.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.divider.withValues(alpha: 0.5),
      ),
    );
  }
}
