import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Immersive full-screen auction page.
///
/// Displays a live auction with video/image background, bid ticker,
/// glassmorphism dock with price + quick-bid buttons, and reaction FABs.
class AuctionLivePage extends StatefulWidget {
  final String title;
  final String currentPrice;
  final String currency;
  final String imageUrl;

  const AuctionLivePage({
    super.key,
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
  // Timer countdown
  Timer? _countdownTimer;
  int _secondsLeft = 45; // start at 00:45

  // Animation for new bids
  late final AnimationController _bidBounceCtrl;

  // Mock bid data — populated from l10n in didChangeDependencies
  List<_BidEntry> _bids = [];
  bool _bidsInitialized = false;

  String _currentDisplayPrice = '';
  int _nextBidAmount = 760000;
  int _fireCount = 12;

  @override
  void initState() {
    super.initState();
    _currentDisplayPrice = widget.currentPrice;

    // Parse price for next bid calculation
    final parsed =
        int.tryParse(widget.currentPrice.replaceAll(',', '')) ?? 750000;
    _nextBidAmount = parsed + 10000;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bidsInitialized) {
      final l10n = AppLocalizations.of(context);
      _bids = [
        _BidEntry(
          name: l10n.auctionBidder1,
          amount: '550,000',
          avatarUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBziPrsdThAFqt5gqE4r6Q2DOaqh7QsQ9uft69hhiwRLp12UZxHdqNWleSm5TYeSqUshOB9Xs7kP2P_Vfnzd9grNhLS5FliPQ6H9yPbj7hqFiL1CIDViUC0OJvGkvcdrXFVGNcAaB40mh_Z3rSYUK3df-ehco_xeaU9O9rQUqBiBW7w9j4tbsXbbDZgNKl_RlXQACR9M1y0SehIFhSQ93cxLUpVE0fFd3g2nJXa1H5EFhY2nXnhnxG9N7Or6eh90pmtx34O9TQQvjh7',
        ),
        _BidEntry(
          name: l10n.auctionBidder2,
          amount: '620,000',
          avatarUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBzUIAszTfeGpyZ7vqttedaKGhrla2VK8dpfKkGb8ey-y3Jn5zIO76MY08ZjLLg1mLZmPB9dmCR0wHGnnOIACtnktgQcZ_c9zF7qg7tdpJ9FwNLf25VqW_VLGzgAu46q99V3IMHVlpqT4_tBS6Y4wMQxMhO-f1rHxw4XfWXVtY2ftnaZVDPRDBrcpWnmX-2xdVRPxR38jUG3sDYfnYL27BjAEGdMREPnRHIorRelZgrIebeJRjP3cbXsDQrdECxd1bjXP6zn0yWpjQP',
        ),
        _BidEntry(
          name: l10n.auctionBidder3,
          amount: '750,000',
          avatarUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAx8ziVXbhF60wr52cGvPDQuQk-5JmVoVs5XChJHKir5vJlv1FQ0FAxCQHoy09g2QD_q5_hkxvqMVZBaIVTgnLh_4kPpbaocoQnAOG1Y7FgKZLaw0Sxx5ltUjvQ2mpJ1y6GbDmX1P2e9GaauhyQTmMIMjqoPsoJecYokNxebH-CQ6gXCFa51xkW4LcttMxsKsbwHBvJDGxO0PkmZKLmmoXnTIhqGkHLUZkI-VbYLzB-hvte6Id37prGNrzaOd0UwG9UADY5asS5Aq5u',
        ),
      ];
      _bidsInitialized = true;
    }
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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _nextBidAmount += increment;
      _currentDisplayPrice = _formatNumber(_nextBidAmount - increment);
      _bids.add(
        _BidEntry(
          name: l10n.auctionYou,
          amount: _formatNumber(_nextBidAmount - increment),
          avatarUrl: '',
          isYou: true,
        ),
      );
      _secondsLeft = 45; // reset timer
      _fireCount++;
    });
    _bidBounceCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          _buildBackground(),

          // 2. Top Navigation
          _buildTopBar(),

          // 3. Bottom Content (bids + dock)
          _buildBottomContent(),

          // 4. Reaction FABs
          _buildReactionButtons(),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────
  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.black),
          ),
          // Top gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────
  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LIVE badge + viewers + seller
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LIVE + viewers
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.liveBadge,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'LIVE',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 1,
                          height: 12.h,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        SizedBox(width: 10.w),
                        Icon(
                          Icons.visibility,
                          size: 14.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '453',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Seller info
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAl9poLKpmWbz4IuZu8tmVuWJ8EumtDyMQTO2Lz2YbnDUsgu2_x8oAPiMujoWP1cTqD-NNivOrSpxW26rG7681cuY--8_jQBCtYwe3rCGqnfbM5WUNzW8oADklvzuGdZ1AL_I0fHTeoc6tVFo9IGAd00gxNFMtdCckzMA93IB__i8pNECtblVSEttWenIDRutWASXKK7TKZsATBdFl5CSxT3NeN44nKssLUtQs0Tk_K7aALuVx3KpIX18JMHh35s2dcT3QKzwHRMBJF',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.auctionSellerName,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '@RoyalBaghdadAuto',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              // Close + Share buttons
              Column(
                children: [
                  _buildCircleButton(Icons.close, () {
                    Navigator.of(context).pop();
                  }),
                  SizedBox(height: 8.h),
                  _buildCircleButton(Icons.ios_share, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Icon(icon, size: 20.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ── Bottom Content ──────────────────────────────────────
  Widget _buildBottomContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.6),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bid ticker
                _buildBidTicker(),
                SizedBox(height: 12.h),

                // Glassmorphism dock
                _buildActionDock(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bid Ticker ──────────────────────────────────────────
  Widget _buildBidTicker() {
    return SizedBox(
      height: 120.h,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
          stops: [0.0, 0.5],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          reverse: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _bids.length,
          itemBuilder: (context, index) {
            final bid = _bids[index];
            final isLatest = index == _bids.length - 1;
            final opacity = isLatest
                ? 1.0
                : (index == _bids.length - 2 ? 0.7 : 0.4);
            final scale = isLatest
                ? 1.0
                : (index == _bids.length - 2 ? 0.95 : 0.9);

            return Transform.scale(
              scale: scale,
              alignment: AlignmentDirectional.centerStart,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar
                      Container(
                        width: isLatest ? 32.w : 24.w,
                        height: isLatest ? 32.w : 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bid.isYou
                              ? AppTheme.primary
                              : Colors.grey[700],
                          border: isLatest
                              ? Border.all(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                )
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: bid.isYou
                            ? Icon(
                                Icons.person,
                                size: 16.sp,
                                color: Colors.black,
                              )
                            : bid.avatarUrl.isNotEmpty
                            ? Image.network(
                                bid.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.person,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                      ),
                      SizedBox(width: 8.w),
                      // Bid bubble
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isLatest
                              ? AppTheme.primary.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            topRight: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r),
                            bottomRight: Radius.circular(2.r),
                          ),
                          border: isLatest
                              ? Border.all(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                )
                              : null,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${bid.name}: ',
                                style: GoogleFonts.cairo(
                                  fontSize: isLatest ? 13.sp : 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '${bid.amount} ${widget.currency}',
                                style: GoogleFonts.inter(
                                  fontSize: isLatest ? 14.sp : 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Glassmorphism Dock ──────────────────────────────────
  Widget _buildActionDock() {
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // ── Current Price + Timer ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.auctionCurrentPrice,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _currentDisplayPrice,
                                style: GoogleFonts.inter(
                                  fontSize: 34.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primary,
                                  letterSpacing: -2,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                widget.currency,
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Timer
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.liveBadge,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formattedTime,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // ── Quick Bid Buttons ────────────────────
              Row(
                children: [
                  _buildQuickBid('+10k', 10000),
                  SizedBox(width: 10.w),
                  _buildQuickBid('+25k', 25000),
                  SizedBox(width: 10.w),
                  _buildQuickBid('+50k', 50000),
                ],
              ),
              SizedBox(height: 14.h),

              // ── Primary Bid Button ──────────────────
              GestureDetector(
                onTap: () => _placeBid(10000),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.auctionBidNowLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              l10n.auctionPlaceYourBid,
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              _formatNumber(_nextBidAmount),
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 20.sp,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickBid(String label, int increment) {
    final l10n = AppLocalizations.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => _placeBid(increment),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Text(
                l10n.auctionIncrease,
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reaction Buttons ────────────────────────────────────
  Widget _buildReactionButtons() {
    return Positioned(
      right: 16.w,
      bottom: 340.h,
      child: Column(
        children: [
          _buildReactionFab(Icons.favorite_border, Colors.white, null, () {}),
          SizedBox(height: 14.h),
          _buildReactionFab(
            Icons.chat_bubble_outline,
            Colors.white,
            null,
            () {},
          ),
          SizedBox(height: 14.h),
          _buildReactionFab(
            Icons.local_fire_department,
            AppTheme.primary,
            _fireCount,
            () {
              setState(() => _fireCount++);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReactionFab(
    IconData icon,
    Color color,
    int? badge,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.75),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(icon, size: 24.sp, color: color),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.liveBadge,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  '$badge',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Data Models ───────────────────────────────────────────
class _BidEntry {
  final String name;
  final String amount;
  final String avatarUrl;
  final bool isYou;

  const _BidEntry({
    required this.name,
    required this.amount,
    required this.avatarUrl,
    this.isYou = false,
  });
}
