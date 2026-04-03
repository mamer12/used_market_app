import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../domain/repositories/auction_repository.dart';

/// Second-Chance Offer page.
///
/// Shown to the second-highest bidder when the winner fails to pay
/// within the deadline. Offers the item at the user's last bid price.
///
/// Based on Stitch Screen 9 (75c720dc).
class SecondChanceOfferPage extends StatefulWidget {
  final String auctionId;
  final String itemTitle;
  final double lastBidPrice;
  final String imageUrl;
  final DateTime expiresAt;
  final String? itemDescription;

  const SecondChanceOfferPage({
    super.key,
    required this.auctionId,
    required this.itemTitle,
    required this.lastBidPrice,
    required this.imageUrl,
    required this.expiresAt,
    this.itemDescription,
  });

  @override
  State<SecondChanceOfferPage> createState() => _SecondChanceOfferPageState();
}

class _SecondChanceOfferPageState extends State<SecondChanceOfferPage> {
  late Timer _countdownTimer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    if (!mounted) return;
    setState(() {
      _remaining = widget.expiresAt.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    if (_remaining == Duration.zero) return '00:00:00';
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 120.h),
                child: Column(
                  children: [
                    _buildHeroIcon(),
                    SizedBox(height: 24.h),
                    _buildTitle(),
                    SizedBox(height: 24.h),
                    _buildProductCard(),
                    SizedBox(height: 24.h),
                    _buildAcceptButton(),
                    SizedBox(height: 12.h),
                    _buildDeclineButton(context),
                  ],
                ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surface,
              ),
              child: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              'لقطة مزادات',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.mazadGreen,
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // ── Hero Icon ─────────────────────────────────────────────────────────────
  Widget _buildHeroIcon() {
    return SizedBox(
      height: 120.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow background
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.mazadGreen.withValues(alpha: 0.08),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mazadGreen.withValues(alpha: 0.12),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Icon
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.mazadGreen.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.stars_rounded,
              size: 48.sp,
              color: AppTheme.mazadGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'فرصة ثانية!',
          style: GoogleFonts.cairo(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'الفائز الأول لم يكمل الدفع في الوقت المحدد. المزاد الآن متاح لك بسعرك الأخير!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── Product Card ──────────────────────────────────────────────────────────
  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.mazadGreen.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mazadGreen.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppTheme.shimmerBase),
                  errorWidget: (_, _, _) =>
                      Container(color: AppTheme.shimmerBase),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      'عرض حصري',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (widget.itemDescription != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    widget.itemDescription!,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                // Price + Countdown row
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.mazadGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'سعرك الأخير',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              IqdFormatter.format(widget.lastBidPrice),
                              style: AppTheme.priceStyle(
                                fontSize: 22.sp,
                                color: AppTheme.mazadGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40.h,
                        width: 1,
                        color: AppTheme.mazadGreen.withValues(alpha: 0.2),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ينتهي خلال',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.schedule_rounded,
                                    color: AppTheme.mazadGreen, size: 16.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  _formattedTime,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.mazadGreen,
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
                SizedBox(height: 16.h),
                // Validity badge
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppTheme.secondary, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'صالح لمدة ٢٤ ساعة فقط',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Accept Button ─────────────────────────────────────────────────────────
  Widget _buildAcceptButton() {
    return GestureDetector(
      onTap: () async {
        await HapticFeedback.mediumImpact();
        try {
          final repository = getIt<AuctionRepository>();
          await repository.acceptSecondChance(widget.auctionId);
          if (mounted) {
            // Navigate to payment page after accepting second chance offer
            await context.push('/payment/zaincash', extra: {
              'orderId': widget.auctionId,
              'paymentUrl': '',
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل قبول العرض: $e'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppTheme.success,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.success.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'قبول العرض والدفع الآن',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.payments_rounded, color: Colors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }

  // ── Decline Button ────────────────────────────────────────────────────────
  Widget _buildDeclineButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.pop();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Text(
          'رفض العرض',
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
