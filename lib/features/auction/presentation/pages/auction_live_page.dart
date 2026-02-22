import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auction_cubit.dart';

/// Immersive full-screen auction page.
///
/// Displays a live auction with video/image background, bid ticker,
/// glassmorphism dock with price + quick-bid buttons, and reaction FABs.
class AuctionLivePage extends StatefulWidget {
  final String auctionId;
  final String title;
  final String currentPrice;
  final String currency;
  final String imageUrl;

  const AuctionLivePage({
    super.key,
    required this.auctionId,
    required this.title,
    required this.currentPrice,
    required this.currency,
    required this.imageUrl,
  });

  @override
  State<AuctionLivePage> createState() => _AuctionLivePageState();
}

class _AuctionLivePageState extends State<AuctionLivePage>
    with TickerProviderStateMixin {
  late final AuctionCubit _cubit;
  // Timer countdown
  Timer? _countdownTimer;
  int _secondsLeft = 45;

  // Animation for new bids
  late final AnimationController _bidBounceCtrl;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionCubit>()..initAuctionLive(widget.auctionId);

    _bidBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Start countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _bidBounceCtrl.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _placeBid(int increment) {
    if (_cubit.state.auction == null) return;
    final currentHigh = _cubit.state.bids.isNotEmpty
        ? _cubit.state.bids.last.amount
        : (_cubit.state.auction?.currentPrice ?? 0);
    final amount = currentHigh + increment;

    _cubit.placeBid(amount);

    setState(() {
      _secondsLeft = 45; // Simulated timer reset
    });

    _bidBounceCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          if (state.isLoading && state.auction == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                _buildBackground(),
                _buildTopBar(),
                _buildMainContent(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Background ──────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.black),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Navigation ──────────────────────────────────────
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Live Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.red[600]?.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red[900]!.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'LIVE',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Back and Share Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(Icons.ios_share, () {}),
                  _buildNavButton(Icons.arrow_forward, () {
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
        ),
      ),
    );
  }

  // ── Main Content ────────────────────────────────────────
  Widget _buildMainContent() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.45 - 60.h,
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            _buildPriceTimer(),
            SizedBox(height: 16.h),
            _buildTrustIndicators(),
            SizedBox(height: 16.h),
            Expanded(child: _buildLiveFeed()),
            _buildBottomControls(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
          ],
        ),
      ),
    );
  }

  // ── Price and Timer ─────────────────────────────────────
  Widget _buildPriceTimer() {
    final currentHigh = _cubit.state.bids.isNotEmpty
        ? _cubit.state.bids.last.amount
        : (_cubit.state.auction?.currentPrice ?? 0);

    return Column(
      children: [
        // Timer
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.red[500],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formattedTime,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.red[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Price
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatNumber(currentHigh),
                  style: GoogleFonts.inter(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.currency,
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'السعر الحالي',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Trust Indicators ────────────────────────────────────
  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTrustChip(Icons.verified_user, 'بائع موثوق'),
        SizedBox(width: 12.w),
        _buildTrustChip(Icons.security, 'دفع آمن عبر زين كاش'),
      ],
    );
  }

  Widget _buildTrustChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  // ── Live Feed ───────────────────────────────────────────
  Widget _buildLiveFeed() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black, // Top fade
          Colors.transparent, // Middle transparent
          Colors.black, // Bottom fade
        ],
        stops: [0.0, 0.2, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstOut,
      child: ListView.builder(
        reverse: true,
        physics: const ClampingScrollPhysics(),
        itemCount: _cubit.state.bids.length > 5 ? 5 : _cubit.state.bids.length,
        itemBuilder: (context, idx) {
          // idx is 0 for newest bid
          final realIdx = _cubit.state.bids.length - 1 - idx;
          final bid = _cubit.state.bids[realIdx];
          final isLatest = idx == 0;
          final scale = isLatest ? 1.0 : (idx == 1 ? 0.95 : 0.9);
          final opacity = isLatest ? 1.0 : (idx == 1 ? 0.7 : 0.4);

          final bidderName =
              'User ...${bid.bidderId.length >= 4 ? bid.bidderId.substring(bid.bidderId.length - 4) : bid.bidderId}';

          return Transform.scale(
            scale: scale,
            alignment: AlignmentDirectional.bottomCenter,
            child: Opacity(
              opacity: opacity,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: isLatest ? 0.1 : 0.05,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bidderName,
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isLatest ? 'منذ لحظات' : 'منذ $idx دقيقة',
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '+ ${_formatNumber(bid.amount)}',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: isLatest
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom Controls ─────────────────────────────────────
  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Bid
        Row(
          children: [
            _buildQuickBidBtn('+ 5k', 5000),
            SizedBox(width: 8.w),
            _buildQuickBidBtn('+ 10k', 10000),
            SizedBox(width: 8.w),
            _buildQuickBidBtn('+ 25k', 25000),
          ],
        ),
        SizedBox(height: 16.h),
        // 3D Bid block
        _AnimatedBidButton(
          onBid: () => _placeBid(10000), // Default bid bump
        ),
        SizedBox(height: 12.h),
        RichText(
          text: TextSpan(
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            children: [
              const TextSpan(text: 'بمزايدتك، أنت توافق على '),
              TextSpan(
                text: 'الشروط والأحكام',
                style: GoogleFonts.cairo(decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickBidBtn(String label, int amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _placeBid(amount),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 3D Bid Button ───────────────────────────────────
class _AnimatedBidButton extends StatefulWidget {
  final VoidCallback onBid;

  const _AnimatedBidButton({required this.onBid});

  @override
  State<_AnimatedBidButton> createState() => _AnimatedBidButtonState();
}

class _AnimatedBidButtonState extends State<_AnimatedBidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _animCtrl.forward();

  void _onTapUp(TapUpDetails details) {
    _animCtrl.reverse();
    widget.onBid();
  }

  void _onTapCancel() => _animCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        // Adjust the shadow offset relative to scale to create a "pressing down" effect
        final isPressed = _animCtrl.value > 0;
        final yOffset = isPressed ? 2.0 : 6.0;
        final innerAlpha = isPressed ? 0.0 : 0.3;

        return Transform.scale(
          scale: _scaleAnim.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              height: 56.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    offset: Offset(0, yOffset),
                    blurRadius: isPressed ? 2 : 10,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    offset: const Offset(0, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Inner depth/highlight
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: innerAlpha),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gavel_rounded,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'مزايدة الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Data Models ───────────────────────────────────────────
