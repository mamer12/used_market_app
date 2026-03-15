import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

class SettlementConfirmPage extends StatelessWidget {
  final String auctionId;
  final String itemTitle;
  final double finalPrice;
  final String imageUrl;
  final String transactionId;

  const SettlementConfirmPage({
    super.key,
    required this.auctionId,
    required this.itemTitle,
    required this.finalPrice,
    required this.imageUrl,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        primaryColor: AppTheme.mazadGreen,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => context.go('/mazadat'),
          ),
          title: Text(
            'تم الدفع بنجاح',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 64.sp),
                ),
                SizedBox(height: 24.h),
                Text(
                  'المبلغ في حساب أمانة مضمون الآن',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'سيتم تحويل ${IqdFormatter.format(finalPrice)} للبائع فقط بعد استلامك للمنتج ($itemTitle)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12121A),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'رقم المعاملة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        transactionId,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.go('/mazadat');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mazadGreen,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: Text(
                    'العودة للرئيسية',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
