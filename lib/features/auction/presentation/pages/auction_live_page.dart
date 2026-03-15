import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../bloc/auction_cubit.dart';
import 'auction_won_page.dart';
import 'widgets/bid_confirmation_sheet.dart';
import 'widgets/outbid_overlay.dart';

/// Live auction bidding page — Iraqi Bazaar Modernism style.
/// Keeps an immersive image hero at top, warm UI controls below.
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

  void _showCustomAmountDialog() {
    _customAmountCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          'مبلغ مخصص',
          style: GoogleFonts.cairo(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: _customAmountCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.cairo(
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل المبلغ بالدينار',
            hintStyle:
                GoogleFonts.cairo(color: AppTheme.textTertiary, fontSize: 14.sp),
            suffixText: 'د.ع',
            suffixStyle: GoogleFonts.cairo(
              color: AppTheme.mazadGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppTheme.textSecondary),
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
            child: Text(
              'زايد',
              style: GoogleFonts.cairo(
                color: AppTheme.mazadGreen,
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
                content:
                    Text(state.error!, style: GoogleFonts.cairo(color: Colors.white)),
                backgroundColor: AppTheme.mazadGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.auction == null) {
            return const Scaffold(
              backgroundColor: AppTheme.background,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.mazadGreen),
              ),
            );
          }

          final currentHigh = state.bids.isNotEmpty
              ? state.bids.last.amount
              : (state.auction?.currentPrice ?? 0);
          final minIncrement = state.auction?.minBidIncrement ?? 10000;
          final viewerCount = 130 + (state.bids.length * 3);

          return Scaffold(
            backgroundColor: AppTheme.background,
            body: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      // ── Header (Stitch Screen 1) ──
                      _buildHeader(context),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              // ── Large Image ──
                              _buildImageHero(),
                              // ── Live badge + viewers + timer row ──
                              _buildStatusRow(viewerCount),
                              // ── Title & condition ──
                              _buildTitleSection(state),
                              // ── Current highest bid card ──
                              _buildCurrentBidCard(currentHigh),
                              // ── Bid history ──
                              _buildBidHistory(state),
                              SizedBox(height: 200.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Glass bottom controls ──
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(
                      currentHigh, minIncrement, state),
                ),
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

  // ── Header (Stitch Screen 1: centered title + auction number) ──
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.arrow_forward_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'مزاد مباشر',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'رقم المزاد: #${widget.auctionId.length >= 4 ? widget.auctionId.substring(widget.auctionId.length - 4) : widget.auctionId}',
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          _NavBtn(icon: Icons.ios_share_rounded, onTap: () {}),
        ],
      ),
    );
  }

  // ── Large rounded image hero (Stitch Screen 1) ──
  Widget _buildImageHero() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: AppTheme.shimmerBase),
              ),
              // Page indicators
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 6.h,
                      width: 24.w,
                      decoration: BoxDecoration(
                        color: AppTheme.mazadGreen,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 6.h,
                      width: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      height: 6.h,
                      width: 6.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3.r),
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
  }

  // ── Status row: Live badge + viewers + timer (Stitch Screen 1) ──
  Widget _buildStatusRow(int viewers) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Row(
        children: [
          // Live badge (red)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border:
                  Border.all(color: AppTheme.accentRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'مباشر',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentRed,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Viewer count
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_rounded,
                  size: 16.sp, color: AppTheme.textTertiary),
              SizedBox(width: 4.w),
              Text(
                '$viewers مشاهد',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Timer pill (dark)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_rounded,
                    size: 14.sp, color: AppTheme.mazadGreen),
                SizedBox(width: 6.w),
                Text(
                  _secondsLeft == 0 ? '--:--:--' : _formattedTime,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Title + condition (Stitch Screen 1) ──
  Widget _buildTitleSection(AuctionState state) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          if (state.auction?.condition != null) ...[
            SizedBox(height: 4.h),
            Text(
              'الحالة: ${state.auction!.condition} • ضمان سنة',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Current highest bid card (Stitch Screen 1: green tinted) ──
  Widget _buildCurrentBidCard(int currentHigh) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppTheme.mazadGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28.r),
        border:
            Border.all(color: AppTheme.mazadGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            'أعلى عطاء حالي',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textTertiary,
            ),
          ),
          SizedBox(height: 4.h),
          ScaleTransition(
            scale: _priceScale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  IqdFormatter.format(currentHigh.toDouble()),
                  style: AppTheme.priceStyle(
                    fontSize: 36.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'د.ع',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mazadGreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded,
                  size: 14.sp, color: AppTheme.mazadGreen),
              SizedBox(width: 4.w),
              Text(
                'سعر المزايدة الأعلى الآن',
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mazadGreen,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bid history (Stitch Screen 1: white cards with avatars) ──
  Widget _buildBidHistory(AuctionState state) {
    final bids = state.bids.reversed.take(5).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل المزايدات المباشر',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'تحديث تلقائي',
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mazadGreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (bids.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  'لا توجد مزايدات بعد\nكن أول مزايد!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...bids.asMap().entries.map((entry) {
              final idx = entry.key;
              final bid = entry.value;
              final isLatest = idx == 0;
              final isMe = bid.bidderId == 'me';
              final masked = isMe
                  ? 'أنت'
                  : 'مزايد ••••${bid.bidderId.length >= 4 ? bid.bidderId.substring(bid.bidderId.length - 4) : bid.bidderId}';

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isLatest ? 1.0 : 0.8,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isLatest
                          ? AppTheme.surfaceAlt
                          : AppTheme.surfaceAlt.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMe
                                ? AppTheme.mazadGreen
                                    .withValues(alpha: 0.2)
                                : AppTheme.surface,
                          ),
                          child: Icon(
                            isMe
                                ? Icons.person_rounded
                                : Icons.person_outline_rounded,
                            color: isMe
                                ? AppTheme.mazadGreen
                                : AppTheme.textTertiary,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                masked,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                isLatest
                                    ? 'منذ لحظات'
                                    : 'منذ ${idx + 1} دقيقة',
                                style: GoogleFonts.cairo(
                                  fontSize: 9.sp,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_fmt(bid.amount)} د.ع',
                          style: AppTheme.priceStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Glass footer bottom controls (Stitch Screen 1) ─────
  Widget _buildBottomControls(
    int currentHigh,
    int minIncrement,
    AuctionState state,
  ) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick bid rail (Stitch: +٥,٠٠٠ / +١٠,٠٠٠ / +٢٥,٠٠٠)
                  Row(
                    children: [
                      _QuickBidBtn(
                        label: '+٥,٠٠٠',
                        onTap: () => _handleBidTap(currentHigh + 5000),
                      ),
                      SizedBox(width: 10.w),
                      _QuickBidBtn(
                        label: '+١٠,٠٠٠',
                        onTap: () => _handleBidTap(currentHigh + 10000),
                      ),
                      SizedBox(width: 10.w),
                      _QuickBidBtn(
                        label: '+٢٥,٠٠٠',
                        onTap: () => _handleBidTap(currentHigh + 25000),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Main bid button (Stitch: green with lock icon)
                  _BigBidButton(
                    isLoading: state.isBidPlacing,
                    onBid: () => _handleBidTap(currentHigh + minIncrement),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'عبر الضغط أنت توافق على شروط المزايدة في مضمون',
                    style: GoogleFonts.cairo(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceAlt,
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 18.sp),
      ),
    );
  }
}

class _QuickBidBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBidBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.divider),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
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
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        HapticFeedback.heavyImpact();
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
              height: 60.h,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mazadGreen.withValues(alpha: 0.4),
                    offset: Offset(0, pressed ? 2 : 6),
                    blurRadius: pressed ? 4 : 14,
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
                        Icon(Icons.lock_rounded,
                            color: AppTheme.textPrimary, size: 22.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'تأكيد المزايدة الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
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
