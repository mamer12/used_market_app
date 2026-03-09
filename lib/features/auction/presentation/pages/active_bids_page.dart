import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

/// Bid History / Active Bids page — "سجل المزايدات".
///
/// Stats grid + filter chips + detailed bid cards with image/status.
///
/// Based on Stitch Screen 2 (5fe820f6).
class ActiveBidsPage extends StatefulWidget {
  const ActiveBidsPage({super.key});

  @override
  State<ActiveBidsPage> createState() => _ActiveBidsPageState();
}

class _ActiveBidsPageState extends State<ActiveBidsPage> {
  int _selectedFilter = 0;

  static const _filters = ['الكل', 'فائز', 'خاسر', 'قيد الانتظار'];

  // Mock data
  final _mockBids = [
    {
      'title': 'آيفون ١٥ برو ماكس',
      'date': '١٥ مايو ٢٠٢٤',
      'amount': 1250000.0,
      'status': 'فائز',
      'statusKey': 'WON',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7L-u9fft9VjVrmtpQUZogxGca3a73ReZl2BQ4Pj-eNbj0oWjZpSrmyykLxgcRwaYiecuHsIXaJjb5O2IMyG1NaFIsnvjMRvpcJihgEP-3zwbuFeBY7Iqvzd5xH10JIg5MTbzw1VGs1rM21S8lYaZ6cGG2-GbJixpPdI4cALImmBfSfpZKJ69swPq1V0PRKQBXHI8VawXEp4ndvXHfs67-EhJXjzTcQRW3EL3UoTtMvTjJaFzbzQ25wApWXgC57_7UIilJBN9Qhz4',
    },
    {
      'title': 'ساعة ذكية ألترا',
      'date': '١٢ مايو ٢٠٢٤',
      'amount': 450000.0,
      'status': 'لم تربح',
      'statusKey': 'LOST',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7L-u9fft9VjVrmtpQUZogxGca3a73ReZl2BQ4Pj-eNbj0oWjZpSrmyykLxgcRwaYiecuHsIXaJjb5O2IMyG1NaFIsnvjMRvpcJihgEP-3zwbuFeBY7Iqvzd5xH10JIg5MTbzw1VGs1rM21S8lYaZ6cGG2-GbJixpPdI4cALImmBfSfpZKJ69swPq1V0PRKQBXHI8VawXEp4ndvXHfs67-EhJXjzTcQRW3EL3UoTtMvTjJaFzbzQ25wApWXgC57_7UIilJBN9Qhz4',
    },
    {
      'title': 'لابتوب الألعاب القوي',
      'date': '٠٨ مايو ٢٠٢٤',
      'amount': 2100000.0,
      'status': 'فائز',
      'statusKey': 'WON',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7L-u9fft9VjVrmtpQUZogxGca3a73ReZl2BQ4Pj-eNbj0oWjZpSrmyykLxgcRwaYiecuHsIXaJjb5O2IMyG1NaFIsnvjMRvpcJihgEP-3zwbuFeBY7Iqvzd5xH10JIg5MTbzw1VGs1rM21S8lYaZ6cGG2-GbJixpPdI4cALImmBfSfpZKJ69swPq1V0PRKQBXHI8VawXEp4ndvXHfs67-EhJXjzTcQRW3EL3UoTtMvTjJaFzbzQ25wApWXgC57_7UIilJBN9Qhz4',
    },
    {
      'title': 'كاميرا احترافية ديجيتال',
      'date': '٠٥ مايو ٢٠٢٤',
      'amount': 890000.0,
      'status': 'لم تربح',
      'statusKey': 'LOST',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB7L-u9fft9VjVrmtpQUZogxGca3a73ReZl2BQ4Pj-eNbj0oWjZpSrmyykLxgcRwaYiecuHsIXaJjb5O2IMyG1NaFIsnvjMRvpcJihgEP-3zwbuFeBY7Iqvzd5xH10JIg5MTbzw1VGs1rM21S8lYaZ6cGG2-GbJixpPdI4cALImmBfSfpZKJ69swPq1V0PRKQBXHI8VawXEp4ndvXHfs67-EhJXjzTcQRW3EL3UoTtMvTjJaFzbzQ25wApWXgC57_7UIilJBN9Qhz4',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  SizedBox(height: 8.h),
                  _buildStatsGrid(),
                  SizedBox(height: 20.h),
                  _buildFilterChips(),
                  SizedBox(height: 16.h),
                  ..._buildBidCards(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppTheme.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              'سجل المزايدات',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.divider),
              ),
              child: Icon(Icons.search_rounded,
                  color: AppTheme.textPrimary, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid (Stitch Screen 2) ──────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: [
                Text(
                  'إجمالي المزايدات',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '٢٤',
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.mazadGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'المزادات الفائزة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '٨',
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isActive = _selectedFilter == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.mazadGreen : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: isActive ? AppTheme.mazadGreen : AppTheme.divider,
                ),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bid Cards ─────────────────────────────────────────────────────────────
  List<Widget> _buildBidCards() {
    return _mockBids.map((bid) {
      final isWon = bid['statusKey'] == 'WON';
      final isLost = bid['statusKey'] == 'LOST';

      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Opacity(
          opacity: isLost ? 0.8 : 1.0,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: bid['image'] as String,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    color: isLost ? Colors.grey : null,
                    colorBlendMode:
                        isLost ? BlendMode.saturation : null,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.shimmerBase),
                    errorWidget: (_, _, _) =>
                        Container(color: AppTheme.shimmerBase),
                  ),
                ),
                SizedBox(width: 12.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bid['title'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  bid['date'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isWon
                                  ? AppTheme.mazadGreen.withValues(alpha: 0.15)
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull),
                            ),
                            child: Text(
                              bid['status'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isWon
                                    ? AppTheme.success
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Bottom row: price + action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مزايدتك الأخيرة',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              Text(
                                IqdFormatter.format(bid['amount'] as double),
                                style: AppTheme.priceStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (isWon)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'التفاصيل',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.mazadGreen,
                                    ),
                                  ),
                                  Icon(Icons.chevron_left_rounded,
                                      color: AppTheme.mazadGreen, size: 18.sp),
                                ],
                              ),
                            )
                          else
                            Text(
                              'انتهى المزاد',
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
