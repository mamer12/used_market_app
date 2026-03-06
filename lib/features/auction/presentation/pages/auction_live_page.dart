import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auction_cubit.dart';
import 'auction_won_page.dart';
import 'widgets/bid_confirmation_sheet.dart';
import 'widgets/outbid_overlay.dart';

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

  Timer? _countdownTimer;
  int _secondsLeft = 0;

  late final AnimationController _priceAnim;
  late final Animation<double> _priceScale;

  // Custom bid amount text field
  final _customAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionCubit>()..initAuctionLive(widget.auctionId);

    _priceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _priceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _priceAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _priceAnim.dispose();
    _customAmountCtrl.dispose();
    super.dispose();
  }

  void _syncCountdown(DateTime? endTime) {
    if (endTime == null) return;
    final diff = endTime.difference(DateTime.now());
    final secs = diff.inSeconds.clamp(0, 99999);
    if (_secondsLeft == secs) return;
    _secondsLeft = secs;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) _secondsLeft--;
      });
    });
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _fmt(int n) {
    final str = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  Future<void> _handleBidTap(int amount) async {
    final current = _cubit.state.bids.isNotEmpty
        ? _cubit.state.bids.last.amount
        : (_cubit.state.auction?.currentPrice ?? 0);

    await BidConfirmationSheet.show(
      context,
      bidAmount: amount,
      currentHighest: current,
      onConfirm: () {
        _cubit.placeBid(amount);
        _priceAnim.forward(from: 0);
      },
    );
  }

  void _showCustomAmountDialog() {
    _customAmountCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'مبلغ مخصص',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: _customAmountCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 18.sp),
          decoration: const InputDecoration(
            hintText: 'Enter amount in IQD',
            hintStyle: TextStyle(color: Colors.white38),
            suffixText: 'IQD',
            suffixStyle: TextStyle(color: AppTheme.primary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(_customAmountCtrl.text);
              if (val != null && val > 0) {
                Navigator.of(ctx).pop();
                _handleBidTap(val);
              }
            },
            child: const Text(
              'Bid',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AuctionCubit, AuctionState>(
        listener: (context, state) {
          // Sync countdown from server endTime
          _syncCountdown(state.auction?.endTime);
          // Auction won — navigate to won page
          if (state.isWon && state.auction != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AuctionWonPage(
                  itemTitle: state.auction!.title,
                  winningBid: state.auction!.currentPrice ?? 0,
                  currency: widget.currency,
                  endTime: state.auction!.endTime ?? DateTime.now(),
                ),
              ),
            );
          }
          // Error snackbar
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: Colors.red[800],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.auction == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }

          final currentHigh = state.bids.isNotEmpty
              ? state.bids.last.amount
              : (state.auction?.currentPrice ?? 0);
          final minIncrement = state.auction?.minBidIncrement ?? 10000;
          final viewerCount = 130 + (state.bids.length * 3);

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // ── Background image ─────────────────────────────
                _buildBackground(),

                // ── Main scrollable content ──────────────────────
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildTopBar(viewerCount),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                SizedBox(height: 12.h),
                                _buildPriceTimer(currentHigh),
                                SizedBox(height: 14.h),
                                _buildTrustChips(),
                                SizedBox(height: 12.h),
                                Expanded(child: _buildBidFeed(state)),
                                _buildBottomControls(
                                  currentHigh,
                                  minIncrement,
                                  state,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                      12.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Outbid overlay (on top of everything) ───────
                if (state.isOutbid)
                  Positioned.fill(
                    child: OutbidOverlay(
                      newHighest: currentHigh,
                      myLastBid: state.myLastBid ?? 0,
                      minIncrement: minIncrement,
                      timeRemaining: _formattedTime,
                      onBidAgain: (amount) {
                        _cubit.clearOutbid();
                        _handleBidTap(amount);
                      },
                      onCustomAmount: () {
                        _cubit.clearOutbid();
                        _showCustomAmountDialog();
                      },
                      onLeave: () => Navigator.of(context).pop(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Background ───────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.height * 0.42,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(color: const Color(0xFF1A1A1A)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.black,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────
  Widget _buildTopBar(int viewers) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          // LIVE badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'LIVE',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.visibility_rounded,
                  size: 13.sp,
                  color: Colors.white70,
                ),
                SizedBox(width: 3.w),
                Text(
                  '$viewers',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _NavBtn(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }

  // ── Price + timer ────────────────────────────────────────
  Widget _buildPriceTimer(int currentHigh) {
    final isUrgent = _secondsLeft < 60 && _secondsLeft > 0;
    return Column(
      children: [
        // Timer pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: (isUrgent ? Colors.red : Colors.white).withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_rounded,
                size: 18.sp,
                color: isUrgent ? Colors.red[400] : Colors.white60,
              ),
              SizedBox(width: 6.w),
              Text(
                _secondsLeft == 0 ? '--:--' : _formattedTime,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: isUrgent ? Colors.red[400] : Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        // Price with bounce animation
        ScaleTransition(
          scale: _priceScale,
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _fmt(currentHigh),
                      style: GoogleFonts.inter(
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: '  ${widget.currency}',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'السعر الحالي',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Trust chips ──────────────────────────────────────────
  Widget _buildTrustChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _TrustChip(
          icon: Icons.verified_user_rounded,
          label: 'بائع موثوق',
        ),
        SizedBox(width: 10.w),
        const _TrustChip(icon: Icons.lock_rounded, label: 'دفع آمن ZainCash'),
      ],
    );
  }

  // ── Bid feed ─────────────────────────────────────────────
  Widget _buildBidFeed(AuctionState state) {
    final bids = state.bids.reversed.take(5).toList();
    if (bids.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مزايدات بعد\nكن أول مزايد!',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      );
    }
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.transparent, Colors.black],
        stops: [0.0, 0.15, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstOut,
      child: ListView.builder(
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bids.length,
        itemBuilder: (_, idx) {
          final bid = bids[idx];
          final isLatest = idx == 0;
          final isMe = bid.bidderId == 'me';
          final masked = isMe
              ? 'أنت'
              : 'User ••••${bid.bidderId.length >= 4 ? bid.bidderId.substring(bid.bidderId.length - 4) : bid.bidderId}';

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isLatest ? 1.0 : (idx == 1 ? 0.7 : 0.4),
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: isLatest ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border(
                    left: BorderSide(
                      color: isLatest
                          ? (isMe ? AppTheme.primary : Colors.white30)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isMe
                            ? AppTheme.primary.withValues(alpha: 0.2)
                            : Colors.grey[800],
                      ),
                      child: Icon(
                        isMe
                            ? Icons.person_rounded
                            : Icons.person_outline_rounded,
                        color: isMe ? AppTheme.primary : Colors.white60,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            masked,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: isMe ? AppTheme.primary : Colors.white,
                            ),
                          ),
                          Text(
                            isLatest ? 'منذ لحظات' : 'منذ ${idx + 1} دقيقة',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${_fmt(bid.amount)}',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isLatest
                            ? AppTheme.primary
                            : AppTheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom controls ──────────────────────────────────────
  Widget _buildBottomControls(
    int currentHigh,
    int minIncrement,
    AuctionState state,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick bid rail
        Row(
          children: [
            _QuickBidBtn(
              label: '+5K',
              onTap: () => _handleBidTap(currentHigh + 5000),
            ),
            SizedBox(width: 8.w),
            _QuickBidBtn(
              label: '+10K',
              onTap: () => _handleBidTap(currentHigh + 10000),
            ),
            SizedBox(width: 8.w),
            _QuickBidBtn(
              label: '+25K',
              onTap: () => _handleBidTap(currentHigh + 25000),
            ),
            SizedBox(width: 8.w),
            _QuickBidBtn(
              icon: Icons.edit_rounded,
              label: 'Custom',
              onTap: _showCustomAmountDialog,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Main 3D bid button
        _BigBidButton(
          isLoading: state.isBidPlacing,
          onBid: () => _handleBidTap(currentHigh + minIncrement),
        ),
        SizedBox(height: 8.h),
        RichText(
          text: TextSpan(
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            children: [
              const TextSpan(text: 'بمزايدتك، أنت توافق على '),
              const TextSpan(
                text: 'الشروط والأحكام',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 13.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBidBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickBidBtn({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: Colors.white70, size: 18.sp)
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class _BigBidButton extends StatefulWidget {
  final VoidCallback onBid;
  final bool isLoading;

  const _BigBidButton({required this.onBid, required this.isLoading});

  @override
  State<_BigBidButton> createState() => _BigBidButtonState();
}

class _BigBidButtonState extends State<_BigBidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onBid();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final pressed = _ctrl.value > 0;
            return Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    offset: Offset(0, pressed ? 2 : 6),
                    blurRadius: pressed ? 4 : 14,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: pressed ? 0 : 0.25),
                    offset: const Offset(0, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gavel_rounded,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'مزايدة الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
