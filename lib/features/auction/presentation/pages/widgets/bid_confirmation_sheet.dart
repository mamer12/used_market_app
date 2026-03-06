import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';

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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
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
              color: Colors.white.withValues(alpha: 0.25),
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You\'re about to place a bid',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.55),
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
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Current Highest • المزايد الحالي',
                  value: '${_fmt(currentHighest)} IQD',
                  valueColor: Colors.white.withValues(alpha: 0.7),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.07),
                    height: 1,
                  ),
                ),
                _SummaryRow(
                  label: 'مبلغ مزايدتك • Your Bid Amount',
                  value: '${_fmt(bidAmount)} IQD',
                  valueColor: AppTheme.primary,
                  valueLarge: true,
                ),
                SizedBox(height: 8.h),
                _SummaryRow(
                  label: 'الفارق • Difference',
                  value: '+${_fmt(diff)} IQD',
                  valueColor: const Color(0xFF34C759),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Warning
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F0A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFFF9F0A).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFFFF9F0A),
                  size: 18.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'يُرجى التأكد من توفر الرصيد في محفظة ZainCash الخاصة بك لتجنب إلغاء العرض.',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFFFF9F0A),
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
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'إلغاء • Cancel',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
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
                    Navigator.of(context).pop(true);
                    onConfirm();
                  },
                  child: Container(
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: Colors.black,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'تأكيد المزايدة • Confirm Bid',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
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
              color: Colors.white.withValues(alpha: 0.35),
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
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: valueLarge ? 20.sp : 14.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
