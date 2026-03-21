import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/iqd_formatter.dart';

// ── Mazadat Theme Constants ──────────────────────────────────────────────────
const _kBg      = Color(0xFF0A0A0F);
const _kSurface = Color(0xFF12121A);
const _kBorder  = Color(0xFF1E1E2A);
const _kPrimary = Color(0xFFFF3D5A);
const _kCyan    = Color(0xFF3CD2EB);
const _kEscrow  = Color(0xFF059669);
const _kTextSec = Color(0xFF9CA3AF);
const _kGold    = Color(0xFFFBBF24);

/// Auction Won Settlement Confirmation screen.
///
/// Shows after the buyer confirms receipt of an item. Releases escrow funds
/// to the seller.
///
/// Constructor params:
/// - [orderId]    — Order/transaction reference number (nullable)
/// - [amount]     — IQD amount released to seller (nullable)
/// - [sellerName] — Seller's display name (nullable)
class SettlementConfirmPage extends StatefulWidget {
  final String? orderId;
  final int? amount;
  final String? sellerName;

  const SettlementConfirmPage({
    super.key,
    this.orderId,
    this.amount,
    this.sellerName,
  });

  @override
  State<SettlementConfirmPage> createState() => _SettlementConfirmPageState();
}

class _SettlementConfirmPageState extends State<SettlementConfirmPage>
    with TickerProviderStateMixin {
  int _starRating = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Back button row ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/mazadat');
                    }
                  },
                ),
              ),
            ),

            // ── Main scrollable content ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),

                    // ── Success icon with glow ring ──────────────────
                    _GlowCheckIcon(animation: _glowAnimation),

                    SizedBox(height: 24.h),

                    // ── Heading ──────────────────────────────────────
                    Text(
                      'تم التأكيد بنجاح!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // ── Subtitle ─────────────────────────────────────
                    Text(
                      'تم تأكيد استلام المنتج. سيتم تحرير المبلغ للبائع خلال ٢٤ ساعة.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: _kTextSec,
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Escrow released badge ─────────────────────────
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: _kEscrow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color: _kEscrow.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_open_rounded,
                            size: 14.sp,
                            color: _kEscrow,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'تم تحرير المبلغ للبائع',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: _kEscrow,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Transaction details card ──────────────────────
                    _TransactionDetailsCard(
                      orderId: widget.orderId,
                      amount: widget.amount,
                    ),

                    SizedBox(height: 28.h),

                    // ── Rating section ────────────────────────────────
                    _RatingSection(
                      sellerName: widget.sellerName,
                      currentRating: _starRating,
                      onRatingChanged: (r) {
                        HapticFeedback.lightImpact();
                        setState(() => _starRating = r);
                      },
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // ── Sticky bottom buttons ────────────────────────────────
            _BottomButtons(
              onHome: () {
                HapticFeedback.mediumImpact();
                context.go('/mazadat');
              },
              onBidHistory: () {
                HapticFeedback.lightImpact();
                context.push('/mazadat/active-bids');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glow Check Icon ──────────────────────────────────────────────────────────
class _GlowCheckIcon extends StatelessWidget {
  final Animation<double> animation;

  const _GlowCheckIcon({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kEscrow.withValues(alpha: animation.value * 0.12),
                border: Border.all(
                  color: _kEscrow.withValues(alpha: animation.value * 0.3),
                  width: 2,
                ),
              ),
            ),
            // Inner check circle
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kEscrow.withValues(alpha: 0.2),
                border: Border.all(
                  color: _kEscrow,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kEscrow.withValues(alpha: animation.value * 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48.sp,
                color: _kEscrow,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Transaction Details Card ─────────────────────────────────────────────────
class _TransactionDetailsCard extends StatelessWidget {
  final String? orderId;
  final int? amount;

  const _TransactionDetailsCard({this.orderId, this.amount});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'رقم الطلب',
            value: orderId ?? '—',
            valueColor: _kCyan,
          ),
          Divider(height: 24.h, color: _kBorder),
          _DetailRow(
            label: 'المبلغ',
            value: amount != null ? IqdFormatter.format(amount!) : '—',
            valueColor: Colors.white,
          ),
          Divider(height: 24.h, color: _kBorder),
          _DetailRow(
            label: 'التاريخ',
            value: dateStr,
            valueColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: _kTextSec,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ── Rating Section ────────────────────────────────────────────────────────────
class _RatingSection extends StatelessWidget {
  final String? sellerName;
  final int currentRating;
  final ValueChanged<int> onRatingChanged;

  const _RatingSection({
    this.sellerName,
    required this.currentRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final prompt = sellerName != null
        ? 'قيّم تجربتك مع $sellerName'
        : 'قيّم تجربتك مع البائع';

    return Column(
      children: [
        Text(
          prompt,
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            final filled = starIndex <= currentRating;
            return GestureDetector(
              onTap: () => onRatingChanged(starIndex),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36.sp,
                  color: filled ? _kGold : _kTextSec,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Bottom Buttons ────────────────────────────────────────────────────────────
class _BottomButtons extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onBidHistory;

  const _BottomButtons({required this.onHome, required this.onBidHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary red pill button
          GestureDetector(
            onTap: onHome,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(999.r),
              ),
              alignment: Alignment.center,
              child: Text(
                'العودة للرئيسية',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Outlined cyan button
          GestureDetector(
            onTap: onBidHistory,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _kCyan, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                'عرض سجل المزايداتي',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _kCyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
