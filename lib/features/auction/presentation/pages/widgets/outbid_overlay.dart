import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';

class OutbidOverlay extends StatefulWidget {
  final int newHighest;
  final int myLastBid;
  final int minIncrement;
  final String timeRemaining; // formatted "MM:SS"
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
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        color: Colors.black.withValues(alpha: 0.80),
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
                      color: const Color(0xFFFF3B30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFF3B30,
                          ).withValues(alpha: 0.45),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 44.sp,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Headline
                Text(
                  'YOU\'VE BEEN OUTBID!',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تمت المزايدة عليك!',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 24.h),

                // Status card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFFF3B30), width: 3),
                    ),
                  ),
                  child: Column(
                    children: [
                      _BidRow(
                        label: 'New Highest Bid',
                        value: '${_fmt(widget.newHighest)} IQD',
                        valueColor: const Color(0xFFFF3B30),
                        large: true,
                      ),
                      SizedBox(height: 8.h),
                      _BidRow(
                        label: 'Your Last Bid',
                        value: '${_fmt(widget.myLastBid)} IQD',
                        valueColor: Colors.white.withValues(alpha: 0.65),
                      ),
                      SizedBox(height: 8.h),
                      _BidRow(
                        label: 'Difference',
                        value: '+${_fmt(diff)} IQD',
                        valueColor: const Color(0xFFFF3B30),
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
                      'Auction ends in  ',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      widget.timeRemaining,
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.h),

                // Bid Again button
                GestureDetector(
                  onTap: () => widget.onBidAgain(nextBid),
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gavel_rounded,
                          color: Colors.black,
                          size: 22.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'BID AGAIN  +${_fmt(widget.minIncrement)} IQD',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
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
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'مبلغ مخصص • Custom Amount',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Leave
                GestureDetector(
                  onTap: widget.onLeave,
                  child: Text(
                    'الانسحاب من المزاد • Leave Auction',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.35),
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
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: large ? 20.sp : 14.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
