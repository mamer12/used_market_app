import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

class AuctionWonPage extends StatelessWidget {
  final String itemTitle;
  final int winningBid;
  final String currency;
  final DateTime endTime;
  final String imageUrl; // Adding imageUrl for UI consistency

  const AuctionWonPage({
    super.key,
    required this.itemTitle,
    required this.winningBid,
    required this.currency,
    required this.endTime,
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDMg7H5F1Cv3WK7932KSjkxdRZCETyCjDCG0cpd7FsKssg8L0Cy41C_lFQOAhjFK11eYV0oU4qVz9-5abGYHBjhsfVGIScj6PZ2tq6Zc1Y7Og3jM4eMWFwcuqddCIGqF95EEdlBSrA_220X7nON6Gt6x4rJgqYyBudsviemUNXjrAZItPwiVUazJ311n87mmKrLcWzQH8g71vWehTBSQyH9e1nmXd20g-ww6fG_Ao1pXqFZBRrL3j1hJq8HDTbVq5i5PGfFqKRMWA',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140F23), // Keeping dark pop background
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
              width: 48.w,
              height: 48.w,
              alignment: Alignment.center,
              child: const Icon(Icons.close_rounded, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              'تأكيد الفوز',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 48.w), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildCelebrationHero() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 240.h),
      decoration: BoxDecoration(
        color: AppTheme.mazadRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.mazadRed.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Icon(
                Icons.celebration_rounded,
                size: 120.w,
                color: AppTheme.mazadRed,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.mazadRed,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  'AUCTION WINNER',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'مبروك!',
                style: GoogleFonts.cairo(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'لقد فزت بالمزاد',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mazadRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'رقم المزاد: #LQ-8829', // Mock ID
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'السعر النهائي',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        IqdFormatter.format(winningBid.toDouble()),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.mazadRed,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowNotice() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.mazadRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: AppTheme.mazadRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حماية الضمان (Escrow)',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'سيتم حجز المبلغ في الضمان بأمان ولا يتم تحويله للبائع حتى استلام المنتج والتأكد منه',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
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
            child: Divider(color: Colors.white.withValues(alpha: 0.1)),
          ),
          _buildSummaryRow(
            'المجموع الكلي',
            IqdFormatter.format(winningBid.toDouble() + 25000),
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
            color: isTotal ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Text(
          amount,
          style: isTotal
              ? GoogleFonts.spaceGrotesk(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.mazadRed,
                )
              : GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
        ),
      ],
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: const Color(0xFF140F23).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mazadRed,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'إتمام الدفع والشحن',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ), // RTL arrow
              ],
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              'تواصل مع البائع',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 28.w,
              ),
              SizedBox(width: 24.w),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 28.w,
              ),
              SizedBox(width: 24.w),
              Icon(
                Icons.verified_user_rounded,
                color: Colors.white.withValues(alpha: 0.4),
                size: 28.w,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
