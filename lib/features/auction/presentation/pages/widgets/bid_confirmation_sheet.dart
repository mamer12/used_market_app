import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';

/// Warm-themed bid confirmation bottom sheet.
class BidConfirmationSheet extends StatelessWidget {
  final int bidAmount;
  final int currentHighest;
  final VoidCallback onConfirm;

  const BidConfirmationSheet({
    super.key,
    required this.bidAmount,
    required this.currentHighest,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int bidAmount,
    required int currentHighest,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BidConfirmationSheet(
        bidAmount: bidAmount,
        currentHighest: currentHighest,
        onConfirm: onConfirm,
      ),
    );
  }

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final diff = bidAmount - currentHighest;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        border: const Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 28.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Header
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تأكيد مزايدتك',
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'تحقق من التفاصيل قبل التأكيد',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Bid summary card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'المزايد الحالي',
                  value: '${_fmt(currentHighest)} د.ع',
                  valueColor: AppTheme.textSecondary,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: const Divider(color: AppTheme.divider, height: 1),
                ),
                _SummaryRow(
                  label: 'مبلغ مزايدتك',
                  value: '${_fmt(bidAmount)} د.ع',
                  valueColor: AppTheme.mazadGreen,
                  valueLarge: true,
                ),
                SizedBox(height: 8.h),
                _SummaryRow(
                  label: 'الفارق',
                  value: '+${_fmt(diff)} د.ع',
                  valueColor: AppTheme.success,
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Warning
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.secondary,
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'يُرجى التأكد من توفر الرصيد في محفظة ZainCash الخاصة بك لتجنب إلغاء العرض.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.secondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(context).pop(true);
                    onConfirm();
                  },
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: AppTheme.mazadGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded,
                            color: AppTheme.textPrimary, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'تأكيد المزايدة',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            'المزايدات ملزمة. قد يؤثر الانسحاب على حسابك.',
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool valueLarge;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: AppTheme.textTertiary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: AppTheme.priceStyle(
            fontSize: valueLarge ? 20.sp : 14.sp,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
