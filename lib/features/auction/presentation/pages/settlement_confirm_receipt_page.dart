import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

/// Mazadat Secure Settlement — Confirm Receipt page.
///
/// Flow: Winner receives item → confirms receipt → escrow releases to seller.
/// Or opens a dispute if item is wrong / not received.
///
/// Based on Stitch Screen 1 (a559f2c9).
class SettlementConfirmReceiptPage extends StatelessWidget {
  final String itemTitle;
  final double finalPrice;
  final String imageUrl;
  final String transactionId;
  final String? auctionId;

  const SettlementConfirmReceiptPage({
    super.key,
    required this.itemTitle,
    required this.finalPrice,
    required this.imageUrl,
    this.transactionId = '#LQ-8829-AX',
    this.auctionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                child: Column(
                  children: [
                    _buildItemCard(),
                    SizedBox(height: 32.h),
                    _buildConfirmSection(context),
                    SizedBox(height: 32.h),
                    _buildDisputeSection(context),
                    SizedBox(height: 24.h),
                    _buildEscrowPolicyInfo(),
                  ],
                ),
              ),
            ),
            _buildTransactionFooter(),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.8),
        border: const Border(bottom: BorderSide(color: AppTheme.surface)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
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
              'تأكيد استلام الطلب',
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

  // ── Item Card ─────────────────────────────────────────────────────────────
  Widget _buildItemCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppTheme.shimmerBase),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.shimmerBase,
                child: const Icon(Icons.image_rounded, color: AppTheme.shimmerHighlight),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'القيمة النهائية للمزاد:',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  IqdFormatter.format(finalPrice),
                  style: AppTheme.priceStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm Receipt Section ───────────────────────────────────────────────
  Widget _buildConfirmSection(BuildContext context) {
    return Column(
      children: [
        // Verified icon
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            color: AppTheme.mazadGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_rounded,
            color: AppTheme.mazadGreen,
            size: 36.sp,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'هل استلمت الطلب بنجاح؟',
          style: GoogleFonts.cairo(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'يرجى التأكد من فحص المنتج جيداً قبل الضغط على زر التأكيد. بمجرد التأكيد، سيتم تحويل المبلغ للبائع مباشرة.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // Big confirm button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            // TODO: call backend confirm receipt API
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.mazadGreen.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppTheme.textPrimary, size: 22.sp),
                SizedBox(width: 10.w),
                Text(
                  'تأكيد الاستلام وإرسال المبلغ',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
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

  // ── Dispute Section ───────────────────────────────────────────────────────
  Widget _buildDisputeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 24.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreenSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(Icons.report_problem_rounded,
                    color: AppTheme.mazadGreen, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'هل تواجه مشكلة؟',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'إذا لم تستلم المنتج، أو كان المنتج مخالفاً للوصف المذكور في المزاد، يرجى فتح نزاع فوراً لتعليق عملية الدفع.',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              // TODO: navigate to dispute flow
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.mazadGreen, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel_rounded,
                      color: AppTheme.mazadGreen, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'فتح نزاع / بلاغ',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.mazadGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Escrow Policy Info ────────────────────────────────────────────────────
  Widget _buildEscrowPolicyInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppTheme.textTertiary, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سياسة حماية المشتري (نظام الأمانة):',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(
                        text: 'يتم حجز الأموال في نظام "لكطة" للوساطة. في حال عدم تأكيد الاستلام أو فتح نزاع خلال ',
                      ),
                      TextSpan(
                        text: '٤٨ ساعة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const TextSpan(
                        text: ' من وقت تسليم الشحنة الموثق، سيقوم النظام تلقائياً بتحرير المبلغ للبائع.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.shield_rounded,
                        color: AppTheme.textTertiary, size: 14.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'حماية كاملة تحت إشراف لكطة',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textTertiary,
                        letterSpacing: 0.5,
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

  // ── Transaction Footer ────────────────────────────────────────────────────
  Widget _buildTransactionFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: AppTheme.surface)),
      ),
      child: Text(
        'رقم المعاملة: $transactionId',
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          color: AppTheme.textTertiary,
        ),
      ),
    );
  }
}
