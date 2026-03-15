import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

/// Auction Won celebration page — "مبروك!" with confetti particles.
///
/// Based on Stitch Screen 4 (c04db738) — warm Iraqi Bazaar Modernism.
class AuctionWonPage extends StatefulWidget {
  final String? auctionId;
  final String itemTitle;
  final int winningBid;
  final String currency;
  final DateTime endTime;
  final String imageUrl;

  const AuctionWonPage({
    super.key,
    this.auctionId,
    required this.itemTitle,
    required this.winningBid,
    required this.currency,
    required this.endTime,
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDMg7H5F1Cv3WK7932KSjkxdRZCETyCjDCG0cpd7FsKssg8L0Cy41C_lFQOAhjFK11eYV0oU4qVz9-5abGYHBjhsfVGIScj6PZ2tq6Zc1Y7Og3jM4eMWFwcuqddCIGqF95EEdlBSrA_220X7nON6Gt6x4rJgqYyBudsviemUNXjrAZItPwiVUazJ311n87mmKrLcWzQH8g71vWehTBSQyH9e1nmXd20g-ww6fG_Ao1pXqFZBRrL3j1hJq8HDTbVq5i5PGfFqKRMWA',
  });

  @override
  State<AuctionWonPage> createState() => _AuctionWonPageState();
}

class _AuctionWonPageState extends State<AuctionWonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
                    _buildCelebrationHero(),
                    _buildWinningItemSummary(),
                    _buildEscrowNotice(),
                    _buildDeadlineNotice(),
                    _buildPaymentSummary(),
                  ],
                ),
              ),
            ),
            _buildStickyFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceAlt,
                border: Border.all(color: AppTheme.divider),
              ),
              child: Icon(Icons.close_rounded, color: AppTheme.textPrimary,
                  size: 20.sp),
            ),
          ),
          Expanded(
            child: Text(
              'تأكيد الفوز',
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

  // ── Celebration Hero with confetti (Stitch Screen 4) ──────────────────────
  Widget _buildCelebrationHero() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 280.h),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.mazadGreen.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          ..._buildConfettiParticles(),
          // Background celebration icon (faded)
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.celebration_rounded,
                size: 160.w,
                color: AppTheme.mazadGreen,
              ),
            ),
          ),
          // Main content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large check in primary ring (Stitch pattern)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.mazadGreen.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppTheme.mazadGreen,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 44.sp,
                  color: AppTheme.mazadGreen,
                ),
              ),
              SizedBox(height: 16.h),
              // Winner badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'الفائز بالمزاد',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'مبروك! 🎉',
                style: GoogleFonts.cairo(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'لقد فزت بالمزاد',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mazadGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Confetti particles ────────────────────────────────────────────────────
  List<Widget> _buildConfettiParticles() {
    final random = math.Random(42);
    final colors = [
      AppTheme.mazadGreen,
      AppTheme.mazadGreen,
      AppTheme.success,
      const Color(0xFF3B82F6),
      const Color(0xFFA855F7),
    ];

    return List.generate(18, (i) {
      final color = colors[i % colors.length];
      final left = random.nextDouble() * 0.85 + 0.05;
      final top = random.nextDouble() * 0.7 + 0.05;
      final size = (random.nextDouble() * 8 + 4).w;
      final isCircle = random.nextBool();

      return AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          final progress = _confettiController.value;
          final offset = math.sin(progress * math.pi * 2 + i) * 6;

          return Positioned(
            left: left * 300.w,
            top: (top * 260.h) + offset,
            child: Opacity(
              opacity: (1 - progress * 0.3).clamp(0.3, 1.0),
              child: Transform.rotate(
                angle: progress * math.pi * (i.isEven ? 1 : -1),
                child: Container(
                  width: size,
                  height: isCircle ? size : size * 0.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle
                        ? null
                        : BorderRadius.circular(1.r),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildWinningItemSummary() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل المنتج',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: AppTheme.cardDecoration,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'رقم المزاد: #LQ-8829',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'السعر النهائي',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                      Text(
                        IqdFormatter.format(widget.winningBid.toDouble()),
                        style: AppTheme.priceStyle(
                          fontSize: 20.sp,
                          color: AppTheme.mazadGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.shimmerBase),
                    errorWidget: (_, _, _) =>
                        Container(color: AppTheme.shimmerBase),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Escrow Notice (Stitch: shield_with_heart + prominent styling) ─────────
  Widget _buildEscrowNotice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.mazadGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppTheme.mazadGreen,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبلغ محجوز في أمانة مضمون',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'سيتم حجز المبلغ في الضمان بأمان ولا يتم تحويله للبائع حتى استلام المنتج والتأكد منه',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 24-Hour Deadline Notice (Stitch Screen 4) ─────────────────────────────
  Widget _buildDeadlineNotice() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreenSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.mazadGreen.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled_rounded,
              color: AppTheme.mazadGreen, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'يرجى إتمام الدفع خلال ٢٤ ساعة لتأكيد الشراء — وإلا قد يُعرض على المزايد التالي.',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.mazadGreen,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildSummaryRow('رسوم المزاد', '25,000 د.ع', isTotal: false),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(color: AppTheme.divider),
          ),
          _buildSummaryRow(
            'المجموع الكلي',
            IqdFormatter.format(widget.winningBid.toDouble() + 25000),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String amount, {
    required bool isTotal,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          amount,
          style: isTotal
              ? AppTheme.priceStyle(
                  fontSize: 20.sp,
                  color: AppTheme.mazadGreen,
                )
              : GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceAlt,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              final id = widget.auctionId ?? 'auction_fallback';
              context.push('/mazadat/payment/$id', extra: {
                'itemTitle': widget.itemTitle,
                'winningBid': widget.winningBid,
                'imageUrl': widget.imageUrl,
              });
            },
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mazadGreen.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إتمام الدفع واستلام السلعة',
                    style: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Icon(Icons.arrow_back_rounded,
                      color: AppTheme.textPrimary), // RTL arrow
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppTheme.divider),
              ),
              alignment: Alignment.center,
              child: Text(
                'تواصل مع البائع',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card_rounded,
                  color: AppTheme.textTertiary, size: 28.w),
              SizedBox(width: 24.w),
              Icon(Icons.account_balance_wallet_rounded,
                  color: AppTheme.textTertiary, size: 28.w),
              SizedBox(width: 24.w),
              Icon(Icons.verified_user_rounded,
                  color: AppTheme.textTertiary, size: 28.w),
            ],
          ),
        ],
      ),
    );
  }
}
