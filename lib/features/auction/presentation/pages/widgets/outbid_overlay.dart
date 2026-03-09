import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';

/// Outbid overlay — warm theme with mazadGreen accents.
class OutbidOverlay extends StatefulWidget {
  final int newHighest;
  final int myLastBid;
  final int minIncrement;
  final String timeRemaining;
  final void Function(int amount) onBidAgain;
  final VoidCallback onCustomAmount;
  final VoidCallback onLeave;

  const OutbidOverlay({
    super.key,
    required this.newHighest,
    required this.myLastBid,
    required this.minIncrement,
    required this.timeRemaining,
    required this.onBidAgain,
    required this.onCustomAmount,
    required this.onLeave,
  });

  @override
  State<OutbidOverlay> createState() => _OutbidOverlayState();
}

class _OutbidOverlayState extends State<OutbidOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
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
    final diff = widget.newHighest - widget.myLastBid;
    final nextBid = widget.newHighest + widget.minIncrement;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        color: AppTheme.background.withValues(alpha: 0.92),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing alert icon
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.mazadGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.bolt_rounded, color: Colors.white, size: 44.sp),
                  ),
                ),
                SizedBox(height: 24.h),

                // Headline
                Text(
                  'تمت المزايدة عليك!',
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'شخص آخر قدم مزايدة أعلى',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),

                // Status card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _BidRow(
                        label: 'أعلى مزايدة جديدة',
                        value: '${_fmt(widget.newHighest)} د.ع',
                        valueColor: AppTheme.mazadGreen,
                        large: true,
                      ),
                      SizedBox(height: 8.h),
                      _BidRow(
                        label: 'مزايدتك الأخيرة',
                        value: '${_fmt(widget.myLastBid)} د.ع',
                        valueColor: AppTheme.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      _BidRow(
                        label: 'الفارق',
                        value: '+${_fmt(diff)} د.ع',
                        valueColor: AppTheme.mazadGreen,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Countdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ينتهي المزاد خلال  ',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      widget.timeRemaining,
                      style: AppTheme.priceStyle(
                        fontSize: 26.sp,
                        color: AppTheme.mazadGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                // Bid Again button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onBidAgain(nextBid);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppTheme.mazadGreen,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gavel_rounded,
                            color: AppTheme.textPrimary, size: 22.sp),
                        SizedBox(width: 10.w),
                        Text(
                          'زايد مرة أخرى  +${_fmt(widget.minIncrement)}',
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
                SizedBox(height: 12.h),

                // Custom amount
                GestureDetector(
                  onTap: widget.onCustomAmount,
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'مبلغ مخصص',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Leave
                GestureDetector(
                  onTap: widget.onLeave,
                  child: Text(
                    'الانسحاب من المزاد',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: AppTheme.textTertiary,
                      decoration: TextDecoration.underline,
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

class _BidRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool large;

  const _BidRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: AppTheme.textTertiary,
          ),
        ),
        Text(
          value,
          style: AppTheme.priceStyle(
            fontSize: large ? 20.sp : 14.sp,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
