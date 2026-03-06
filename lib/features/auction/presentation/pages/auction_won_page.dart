import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/app_theme.dart';

class AuctionWonPage extends StatefulWidget {
  final String itemTitle;
  final int winningBid;
  final String currency;
  final DateTime endTime;

  const AuctionWonPage({
    super.key,
    required this.itemTitle,
    required this.winningBid,
    required this.currency,
    required this.endTime,
  });

  @override
  State<AuctionWonPage> createState() => _AuctionWonPageState();
}

class _AuctionWonPageState extends State<AuctionWonPage>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _glowAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  Timer? _paymentTimer;
  Duration _paymentDue = const Duration(hours: 24);

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_paymentDue.inSeconds > 0) {
        setState(() => _paymentDue -= const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _entryCtrl.dispose();
    _paymentTimer?.cancel();
    super.dispose();
  }

  String get _paymentCountdown {
    final h = _paymentDue.inHours.toString().padLeft(2, '0');
    final m = (_paymentDue.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_paymentDue.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                // Confetti / sparkle zone
                SizedBox(
                  height: 180.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow rings
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, _) => Container(
                          width: 140.w * _glowAnim.value,
                          height: 140.w * _glowAnim.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withValues(
                              alpha: 0.08 * _glowAnim.value,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      // Sparkles
                      ...List.generate(8, (i) {
                        final angle = (i * pi / 4);
                        final r = 62.w;
                        return Positioned(
                          left: 90.w + cos(angle) * r - 4,
                          top: 90.h + sin(angle) * r - 4,
                          child: AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (_, _) => Opacity(
                              opacity: _glowAnim.value,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Trophy
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Text('🏆', style: TextStyle(fontSize: 64.sp)),
                      ),
                    ],
                  ),
                ),

                // Winner title
                Text(
                  '🎉 You Won!',
                  style: GoogleFonts.inter(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'مبروك! أنت الفائز',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 28.h),

                // Auction summary card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${_fmt(widget.winningBid)} ${widget.currency}',
                        style: GoogleFonts.inter(
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        'Your Winning Bid',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: Colors.white.withValues(alpha: 0.06)),
                      SizedBox(height: 8.h),
                      Text(
                        'Ended: ${widget.endTime.day}/${widget.endTime.month}/${widget.endTime.year}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Payment countdown
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        color: const Color(0xFFFF3B30),
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Payment due in  ',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                      Text(
                        _paymentCountdown,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Pay Now button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Pay Now via ZainCash',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Secondary actions
                Row(
                  children: [
                    Expanded(
                      child: _GhostButton(
                        label: 'View Item',
                        icon: Icons.open_in_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _GhostButton(
                        label: 'Share Win 🎉',
                        icon: Icons.share_rounded,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Need help? Contact seller',
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

class _GhostButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
