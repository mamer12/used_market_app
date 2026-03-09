import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

/// Auction Lost — "حظاً أوفر" (Better Luck Next Time) page.
///
/// Shown when a user loses an auction. Displays closing info +
/// horizontally-scrollable similar auctions.
///
/// Based on Stitch Screen 5 (b84fa346).
class AuctionLostPage extends StatelessWidget {
  final String itemTitle;
  final double closingPrice;
  final String winnerInitials;
  final String? imageUrl;

  const AuctionLostPage({
    super.key,
    required this.itemTitle,
    required this.closingPrice,
    this.winnerInitials = 'أ.م.',
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildLostHero(),
                    SizedBox(height: 8.h),
                    _buildClosingDetails(),
                    SizedBox(height: 32.h),
                    _buildSimilarAuctions(context),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(context),
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
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.arrow_forward_rounded, color: AppTheme.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              'انتهى المزاد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // ── Lost Hero ─────────────────────────────────────────────────────────────
  Widget _buildLostHero() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 40.sp,
              color: AppTheme.textTertiary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'حظاً أوفر',
            style: GoogleFonts.cairo(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يحالفك الحظ هذه المرة في الفوز بالمزاد',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Closing Details ───────────────────────────────────────────────────────
  Widget _buildClosingDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سعر الإغلاق النهائي:',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                IqdFormatter.format(closingPrice),
                style: AppTheme.priceStyle(
                  fontSize: 20.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(color: AppTheme.divider),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المزايد الفائز:',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Row(
                children: [
                  Text(
                    winnerInitials,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      winnerInitials.replaceAll('.', '').trim().substring(0, 2),
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Similar Auctions ──────────────────────────────────────────────────────
  Widget _buildSimilarAuctions(BuildContext context) {
    final mockSimilar = [
      {'title': 'ساعة يد ذكية - إصدار محدود', 'price': 120000.0, 'time': '٠٢:٤٥:١٢'},
      {'title': 'كاميرا احترافية بدقة عالية', 'price': 850000.0, 'time': '١٠:١٥:٠٠'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مزادات مشابهة قد تعجبك',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/mazadat'),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mazadGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 260.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: mockSimilar.length,
            separatorBuilder: (_, _) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final item = mockSimilar[index];
              return _SimilarAuctionCard(
                title: item['title'] as String,
                currentPrice: item['price'] as double,
                timeLeft: item['time'] as String,
                imageUrl: imageUrl ??
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB7L-u9fft9VjVrmtpQUZogxGca3a73ReZl2BQ4Pj-eNbj0oWjZpSrmyykLxgcRwaYiecuHsIXaJjb5O2IMyG1NaFIsnvjMRvpcJihgEP-3zwbuFeBY7Iqvzd5xH10JIg5MTbzw1VGs1rM21S8lYaZ6cGG2-GbJixpPdI4cALImmBfSfpZKJ69swPq1V0PRKQBXHI8VawXEp4ndvXHfs67-EhJXjzTcQRW3EL3UoTtMvTjJaFzbzQ25wApWXgC57_7UIilJBN9Qhz4',
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────
  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/mazadat');
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.textPrimary, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gavel_rounded, color: AppTheme.textPrimary, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'العودة للمزادات',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Similar Auction Card ────────────────────────────────────────────────────
class _SimilarAuctionCard extends StatelessWidget {
  final String title;
  final double currentPrice;
  final String timeLeft;
  final String imageUrl;

  const _SimilarAuctionCard({
    required this.title,
    required this.currentPrice,
    required this.timeLeft,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 130.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppTheme.shimmerBase),
                  errorWidget: (_, _, _) =>
                      Container(color: AppTheme.shimmerBase),
                ),
                // Timer badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded,
                            color: AppTheme.mazadGreen, size: 13.sp),
                        SizedBox(width: 4.w),
                        Text(
                          timeLeft,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
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
          // Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أعلى عطاء حالي',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          IqdFormatter.format(currentPrice),
                          style: AppTheme.priceStyle(
                            fontSize: 14.sp,
                            color: AppTheme.mazadGreen,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        'زايد الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
