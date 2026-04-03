import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../bloc/auction_cubit.dart';
import 'auction_won_page.dart';
import '../widgets/auction_clips_row.dart';
import 'widgets/bid_confirmation_sheet.dart';
import 'widgets/outbid_overlay.dart';

// ── Mazadat Dark Palette ──────────────────────────────────────────────────────
const _bg         = Color(0xFF0A0A0F);
const _surface    = Color(0xFF12121A);
const _border     = Color(0xFF1E1E2A);
const _primary    = Color(0xFFFF3D5A);   // red-pink
const _cyan       = Color(0xFF3CD2EB);   // secondary / cyan
const _textWhite  = Color(0xFFFFFFFF);
const _textSec    = Color(0xFF9CA3AF);
const _textTert   = Color(0xFF6B7280);

/// Mazadat — Live Auction Detail Page (dark Stitch design).
///
/// Keeps all BLoC connections (AuctionCubit, WebSocket) from the original.
/// Falls back to mock data when cubit state is initial / loading.
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

  // Price-flash animation
  late final AnimationController _priceAnim;
  late final Animation<double> _priceScale;

  // Countdown pulse animation (red when < 10 s)
  late final AnimationController _pulseCtrl;

  // Carousel state
  int _carouselIndex = 0;
  final _pageCtrl = PageController();

  // Manual bid input
  final _manualBidCtrl = TextEditingController();

  // Bid history expansion
  bool _bidHistoryExpanded = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionCubit>()..initAuctionLive(widget.auctionId);

    _priceAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _priceScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _priceAnim, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _priceAnim.dispose();
    _pulseCtrl.dispose();
    _pageCtrl.dispose();
    _manualBidCtrl.dispose();
    super.dispose();
  }

  // ── Countdown helpers ─────────────────────────────────────────────────────

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
    if (_secondsLeft <= 0) return '--:--';
    final h = (_secondsLeft ~/ 3600);
    final m = ((_secondsLeft % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  bool get _isUrgent => _secondsLeft > 0 && _secondsLeft < 10;

  // ── Bid actions ───────────────────────────────────────────────────────────

  Future<void> _handleBidTap(int amount) async {
    unawaited(HapticFeedback.mediumImpact());
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

  void _submitManualBid() {
    final val = int.tryParse(
      _manualBidCtrl.text.replaceAll(',', '').trim(),
    );
    if (val != null && val > 0) {
      _manualBidCtrl.clear();
      _handleBidTap(val);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AuctionCubit, AuctionState>(
        listener: (context, state) {
          _syncCountdown(state.auction?.endTime);
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
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: GoogleFonts.cairo(color: _textWhite),
                ),
                backgroundColor: _primary,
              ),
            );
          }
        },
        builder: (context, state) {
          // Loading skeleton
          if (state.isLoading && state.auction == null) {
            return const Scaffold(
              backgroundColor: _bg,
              body: Center(
                child: CircularProgressIndicator(color: _cyan),
              ),
            );
          }

          // Mock fallback when cubit is initial / empty
          final currentHigh = state.bids.isNotEmpty
              ? state.bids.last.amount
              : (state.auction?.currentPrice ?? 2500000);
          final minIncrement = state.auction?.minBidIncrement ?? 50000;
          final bidCount = state.bids.isNotEmpty
              ? state.bids.length
              : 23;
          final images = (state.auction?.images.isNotEmpty ?? false)
              ? state.auction!.images
              : [widget.imageUrl];

          return Scaffold(
            backgroundColor: _bg,
            body: Stack(
              children: [
                // ── Scrollable body ──
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCarousel(images),
                              SizedBox(height: 20.h),
                              _buildProductInfo(state),
                              SizedBox(height: 16.h),
                              _buildCurrentBidCard(currentHigh, bidCount),
                              SizedBox(height: 16.h),
                              const AuctionClipsRow(clips: []),
                              SizedBox(height: 12.h),
                              _buildStatsRow(minIncrement),
                              SizedBox(height: 20.h),
                              _buildQuickBidSection(currentHigh),
                              SizedBox(height: 16.h),
                              _buildManualBidInput(),
                              SizedBox(height: 20.h),
                              _buildBidHistory(state, bidCount),
                              SizedBox(height: 20.h),
                              _buildSellerSection(),
                              SizedBox(height: 16.h),
                              _buildActivitySection(),
                              SizedBox(height: 130.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom CTA ──
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomCta(currentHigh, minIncrement, state),
                ),

                // ── Outbid overlay ──
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

  // ── AppBar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _bg,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _CircleBtn(
            icon: Icons.arrow_forward_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            'تفاصيل المزاد',
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: _textWhite,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _CircleBtn(
                icon: Icons.ios_share_rounded,
                onTap: () {},
              ),
              SizedBox(width: 8.w),
              // LIVE pill badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        color: _textWhite,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'LIVE',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: _textWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image carousel ────────────────────────────────────────────────────────

  Widget _buildCarousel(List<String> images) {
    final count = images.isEmpty ? 1 : images.length;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _pageCtrl,
                itemCount: count,
                onPageChanged: (i) => setState(() => _carouselIndex = i),
                itemBuilder: (_, i) {
                  final url = images.isNotEmpty ? images[i] : '';
                  return url.isNotEmpty
                      ? Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: _surface,
                            child: const Icon(Icons.image_not_supported_outlined,
                                color: _textTert),
                          ),
                        )
                      : Container(
                          color: _surface,
                          child: const Icon(Icons.image_outlined,
                              color: _textTert, size: 48),
                        );
                },
              ),
              // Page indicator dots
              Positioned(
                bottom: 14.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(count, (i) {
                    final active = i == _carouselIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      height: 6.h,
                      width: active ? 20.w : 6.w,
                      decoration: BoxDecoration(
                        color: active ? _cyan : _textTert,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Product info ──────────────────────────────────────────────────────────

  Widget _buildProductInfo(AuctionState state) {
    final title = state.auction?.title.isNotEmpty == true
        ? state.auction!.title
        : widget.title;
    final condition = state.auction?.condition;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: _textWhite,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Condition badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  condition?.isNotEmpty == true ? condition! : 'ممتاز',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              // Verified icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded,
                      color: _cyan, size: 14),
                  SizedBox(width: 4.w),
                  Text(
                    'موثق',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: _cyan,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Current bid card ──────────────────────────────────────────────────────

  Widget _buildCurrentBidCard(int currentHigh, int bidCount) {
    // Mock original price (20% below current for display)
    final originalPrice = (currentHigh * 0.72).toInt();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المزايدة الحالية',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: _textSec,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: _priceScale,
                  child: Text(
                    IqdFormatter.format(currentHigh.toDouble()),
                    style: GoogleFonts.cairo(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: _cyan,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Crossed-out original price
                  Text(
                    IqdFormatter.format(originalPrice.toDouble()),
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: _textTert,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Bidder count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          color: _textSec, size: 14),
                      SizedBox(width: 4.w),
                      Text(
                        '$bidCount مزايد',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: _textSec,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(int minIncrement) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.trending_up_rounded,
            label: '${IqdFormatter.format(minIncrement.toDouble())} أقل زيادة',
            color: _cyan,
          ),
          SizedBox(width: 10.w),
          // Countdown pill
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, _) {
              final timerColor = _isUrgent
                  ? Color.lerp(_primary, const Color(0xFFFF8C92),
                      _pulseCtrl.value)!
                  : _cyan;
              return _StatChip(
                icon: Icons.timer_outlined,
                label: _secondsLeft == 0 ? '--:--' : _formattedTime,
                color: timerColor,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Quick bid section ─────────────────────────────────────────────────────

  Widget _buildQuickBidSection(int currentHigh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'زيادة سريعة',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _textWhite,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _QuickBidChip(
                label: '+٥٠,٠٠٠',
                onTap: () => _handleBidTap(currentHigh + 50000),
              ),
              SizedBox(width: 8.w),
              _QuickBidChip(
                label: '+١٠٠,٠٠٠',
                onTap: () => _handleBidTap(currentHigh + 100000),
              ),
              SizedBox(width: 8.w),
              _QuickBidChip(
                label: '+٢٥٠,٠٠٠',
                onTap: () => _handleBidTap(currentHigh + 250000),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Manual bid input ──────────────────────────────────────────────────────

  Widget _buildManualBidInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _manualBidCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  color: _textWhite,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل مبلغ المزايدة اليدوي',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: _textTert,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  suffixText: 'د.ع',
                  suffixStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: _textSec,
                  ),
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            GestureDetector(
              onTap: _submitManualBid,
              child: Container(
                margin: EdgeInsets.all(6.r),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 10.h,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'زايد',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bid history ───────────────────────────────────────────────────────────

  Widget _buildBidHistory(AuctionState state, int bidCount) {
    final realBids = state.bids.reversed.toList();

    // Mock bids when list is empty
    final mockBids = List.generate(
      5,
      (i) => _MockBid(
        initial: ['م', 'أ', 'ع', 'ط', 'ب'][i],
        name: ['مزايد ${i + 1}', 'مزايد ${i + 2}', 'مزايد ${i + 3}',
            'مزايد ${i + 4}', 'مزايد ${i + 5}'][i],
        amount: 2500000 - (i * 50000),
        minutesAgo: i == 0 ? 0 : i,
      ),
    );

    final useMock = realBids.isEmpty;
    final displayCount = useMock ? mockBids.length : realBids.length;
    final visibleCount = _bidHistoryExpanded ? displayCount : displayCount.clamp(0, 3);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row — expandable
          GestureDetector(
            onTap: () =>
                setState(() => _bidHistoryExpanded = !_bidHistoryExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل المزايدات ($bidCount)',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _textWhite,
                  ),
                ),
                Icon(
                  _bidHistoryExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _textSec,
                  size: 22.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (useMock)
            ...mockBids.take(visibleCount).map((bid) => _BidHistoryRow(
              initial: bid.initial,
              name: bid.name,
              timeLabel: bid.minutesAgo == 0 ? 'منذ لحظات' : 'منذ ${bid.minutesAgo} دقيقة',
              amount: bid.amount,
              isLatest: bid.minutesAgo == 0,
              isMe: false,
            ))
          else
            ...List.generate(visibleCount, (idx) {
              final b = realBids[idx];
              final isMe = b.bidderId == 'me';
              return _BidHistoryRow(
                initial: isMe ? 'أ' : 'م',
                name: isMe
                    ? 'أنت'
                    : 'مزايد ••••${b.bidderId.length >= 4 ? b.bidderId.substring(b.bidderId.length - 4) : b.bidderId}',
                timeLabel: idx == 0 ? 'منذ لحظات' : 'منذ ${idx + 1} دقيقة',
                amount: b.amount,
                isLatest: idx == 0,
                isMe: isMe,
              );
            }),
        ],
      ),
    );
  }

  // ── Seller section ────────────────────────────────────────────────────────

  Widget _buildSellerSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'البائع',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: _textWhite,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      'م',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'متجر التفاحة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _textWhite,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFB800), size: 14),
                          SizedBox(width: 3.w),
                          Text(
                            '4.9',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: _textSec,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '(١٢٤ تقييم)',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              color: _textTert,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: _cyan),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'عرض',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _cyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Activity section ──────────────────────────────────────────────────────

  Widget _buildActivitySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'النشاط مرتفع جداً',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _textWhite,
              ),
            ),
            const Spacer(),
            const _ActivityStat(icon: Icons.visibility_outlined, value: '١.٢ك'),
            SizedBox(width: 16.w),
            const _ActivityStat(
                icon: Icons.favorite_outline_rounded, value: '٨٤'),
          ],
        ),
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────

  Widget _buildBottomCta(
    int currentHigh,
    int minIncrement,
    AuctionState state,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Row(
            children: [
              // Current bid display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'المزايدة الحالية',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: _textTert,
                      ),
                    ),
                    Text(
                      IqdFormatter.format(currentHigh.toDouble()),
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _cyan,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              // "زايد الآن" button
              GestureDetector(
                onTap: state.isBidPlacing
                    ? null
                    : () => _handleBidTap(currentHigh + minIncrement),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: state.isBidPlacing
                        ? _primary.withValues(alpha: 0.6)
                        : _primary,
                    borderRadius: BorderRadius.circular(999.r),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: state.isBidPlacing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: _textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'زايد الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: _textWhite,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

/// Mock bid data for initial/empty state fallback.
class _MockBid {
  final String initial;
  final String name;
  final int amount;
  final int minutesAgo;

  const _MockBid({
    required this.initial,
    required this.name,
    required this.amount,
    required this.minutesAgo,
  });
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _surface,
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _textWhite, size: 18.sp),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBidChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBidChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 11.h),
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: _primary.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _BidHistoryRow extends StatelessWidget {
  final String initial;
  final String name;
  final String timeLabel;
  final int amount;
  final bool isLatest;
  final bool isMe;

  const _BidHistoryRow({
    required this.initial,
    required this.name,
    required this.timeLabel,
    required this.amount,
    required this.isLatest,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = isMe ? _primary : _cyan;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isLatest ? _surface : _surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isLatest ? _border.withValues(alpha: 0.8) : _border,
          ),
        ),
        child: Row(
          children: [
            // Avatar initials
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: avatarColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: _textWhite,
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 10.sp,
                      color: _textTert,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              IqdFormatter.format(amount.toDouble()),
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isLatest ? _cyan : _textSec,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ActivityStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _textTert, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            color: _textSec,
          ),
        ),
      ],
    );
  }
}
