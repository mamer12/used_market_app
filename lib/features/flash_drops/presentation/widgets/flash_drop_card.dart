import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_theme.dart';
import '../../data/models/flash_drop_model.dart';
import 'flash_countdown_timer.dart';

class FlashDropCard extends StatelessWidget {
  final FlashDropModel drop;
  final VoidCallback? onBuyTap;

  const FlashDropCard({super.key, required this.drop, this.onBuyTap});

  String _formatPrice(int amount) {
    return '${NumberFormat('#,###', 'ar_IQ').format(amount)} د.ع';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                drop.productImageUrl,
                width: double.infinity,
                height: 80.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  height: 80.h,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.image_outlined,
                    size: 32.sp,
                    color: AppTheme.inactive,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // Shop name
            Text(
              drop.shopName,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),

            // Product title
            Text(
              drop.productName,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),

            // Prices
            Text(
              _formatPrice(drop.originalPrice),
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                color: AppTheme.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              _formatPrice(drop.flashPrice),
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF3D5A),
              ),
            ),
            SizedBox(height: 6.h),

            // Countdown
            FlashCountdownTimer(endsAt: drop.endsAt),
            SizedBox(height: 8.h),

            // Buy button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBuyTap ?? () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'اشتري الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
