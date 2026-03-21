import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/iqd_formatter.dart';

// ── Mazadat dark palette (Stitch) ─────────────────────────────────────────
const Color _kBg        = Color(0xFF0A0A0F);
const Color _kSurface   = Color(0xFF12121A);
const Color _kBorder    = Color(0xFF1E1E2A);
const Color _kPrimary   = Color(0xFFFF3D5A); // red-pink
const Color _kCyan      = Color(0xFF00F5FF); // secondary
const Color _kEscrow    = Color(0xFF059669); // green
const Color _kTextPri   = Color(0xFFFFFFFF);
const Color _kTextSec   = Color(0xFF9CA3AF);

/// Auction Won & Settlement page — Stitch Mazadat dark design.
///
/// Shows winner celebration banner, auction summary, escrow status timeline,
/// payment breakdown, and contact seller actions.
class AuctionWonPage extends StatefulWidget {
  final String? auctionId;
  final String itemTitle;
  final int winningBid;
  final String currency;
  final DateTime endTime;
  final String imageUrl;

  const AuctionWonPage({
    super.key,
    this.auctionId,
    required this.itemTitle,
    required this.winningBid,
    required this.currency,
    required this.endTime,
    this.imageUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDDMg7H5F1Cv3WK7932KSjkxdRZCETyCjDCG0cpd7FsKssg8L0Cy41C_lFQOAhjFK11eYV0oU4qVz9-5abGYHBjhsfVGIScj6PZ2tq6Zc1Y7Og3jM4eMWFwcuqddCIGqF95EEdlBSrA_220X7nON6Gt6x4rJgqYyBudsviemUNXjrAZItPwiVUazJ311n87mmKrLcWzQH8g71vWehTBSQyH9e1nmXd20g-ww6fG_Ao1pXqFZBRrL3j1hJq8HDTbVq5i5PGfFqKRMWA',
  });

  @override
  State<AuctionWonPage> createState() => _AuctionWonPageState();
}

class _AuctionWonPageState extends State<AuctionWonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildCelebrationBanner(),
                    SizedBox(height: 16.h),
                    _buildAuctionSummaryCard(),
                    SizedBox(height: 16.h),
                    _buildEscrowSection(),
                    SizedBox(height: 16.h),
                    _buildPaymentSection(),
                    SizedBox(height: 16.h),
                    _buildContactSellerCard(context),
                    SizedBox(height: 16.h),
                    _buildNextSteps(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(bottom: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kBg,
                border: Border.all(color: _kBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextPri,
                size: 16.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'الفائز بالمزاد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: _kTextPri,
              ),
            ),
          ),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  // ── Winner Celebration Banner ───────────────────────────────────────────
  Widget _buildCelebrationBanner() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: _kCyan.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          ..._buildConfettiParticles(),
          // Main content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with cyan glow
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kCyan.withValues(alpha: 0.1),
                  border: Border.all(color: _kCyan.withValues(alpha: 0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _kCyan.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 38.sp,
                  color: _kCyan,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'مبروك! لقد فزت بالمزاد',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: _kCyan,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                widget.itemTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: _kTextSec,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiParticles() {
    final random = math.Random(42);
    final colors = [_kCyan, _kPrimary, const Color(0xFF3cd2eb)];

    return List.generate(14, (i) {
      final color = colors[i % colors.length];
      final left  = random.nextDouble() * 0.8 + 0.05;
      final top   = random.nextDouble() * 0.6 + 0.05;
      final size  = (random.nextDouble() * 6 + 3).w;
      final isCircle = random.nextBool();

      return AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          final progress = _confettiController.value;
          final offset = math.sin(progress * math.pi * 2 + i) * 5;

          return Positioned(
            left: left * 280.w,
            top: (top * 160.h) + offset,
            child: Opacity(
              opacity: (1 - progress * 0.4).clamp(0.2, 1.0),
              child: Transform.rotate(
                angle: progress * math.pi * (i.isEven ? 1 : -1),
                child: Container(
                  width: size,
                  height: isCircle ? size : size * 0.5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        isCircle ? null : BorderRadius.circular(1.r),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  // ── Auction Summary Card ────────────────────────────────────────────────
  Widget _buildAuctionSummaryCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product image thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: const Color(0xFF1E1E2A)),
                  errorWidget: (_, _, _) =>
                      Container(color: const Color(0xFF1E1E2A)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.itemTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: _kTextPri,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'حالة جيدة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: _kTextSec,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'سعر الفوز',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: _kTextSec,
                      ),
                    ),
                    Text(
                      IqdFormatter.format(widget.winningBid.toDouble()),
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: _kCyan,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: _kBorder, height: 1),
          SizedBox(height: 14.h),
          // Seller info row
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kBorder,
                  border: Border.all(color: _kBorder),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 18.sp,
                  color: _kTextSec,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'البائع',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: _kTextSec,
                    ),
                  ),
                  Text(
                    'أحمد محمد',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: _kTextPri,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _kEscrow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border:
                      Border.all(color: _kEscrow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 12.sp, color: _kEscrow),
                    SizedBox(width: 4.w),
                    Text(
                      'بائع موثق',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: _kEscrow,
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

  // ── Escrow Status Section ───────────────────────────────────────────────
  Widget _buildEscrowSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الضمان',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: _kTextPri,
            ),
          ),
          SizedBox(height: 12.h),
          // Escrow badge
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _kEscrow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _kEscrow.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kEscrow.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    Icons.lock_rounded,
                    size: 20.sp,
                    color: _kEscrow,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ محجوز في أمانة مضمون',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: _kEscrow,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'لن يُحوَّل للبائع إلا بعد استلام المنتج',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: _kTextSec,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Status timeline: 4 steps
          _buildStatusTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final steps = [
      ('دفع', Icons.payment_rounded, true),
      ('شحن', Icons.local_shipping_rounded, false),
      ('استلام', Icons.inbox_rounded, false),
      ('تحرير', Icons.check_circle_rounded, false),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final isActiveConnector = i == 1; // between step 0 and step 1 (current)
          return Expanded(
            child: Container(
              height: 2.h,
              color: isActiveConnector
                  ? _kCyan.withValues(alpha: 0.5)
                  : _kBorder,
            ),
          );
        }
        final idx   = i ~/ 2;
        final step  = steps[idx];
        final isActive = idx == 0; // current step

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? _kCyan.withValues(alpha: 0.2)
                    : _kBorder,
                border: Border.all(
                  color: isActive ? _kCyan : _kBorder,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _kCyan.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                step.$2,
                size: 16.sp,
                color: isActive ? _kCyan : _kTextSec,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              step.$1,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? _kCyan : _kTextSec,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Payment Section ─────────────────────────────────────────────────────
  Widget _buildPaymentSection() {
    final serviceFee   = 25000.0;
    final total        = widget.winningBid.toDouble() + serviceFee;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الدفع',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: _kTextPri,
            ),
          ),
          SizedBox(height: 14.h),
          _buildPaymentRow(
            'المبلغ المطلوب',
            IqdFormatter.format(widget.winningBid.toDouble()),
          ),
          SizedBox(height: 10.h),
          _buildPaymentRow(
            'رسوم الخدمة',
            IqdFormatter.format(serviceFee),
          ),
          SizedBox(height: 12.h),
          const Divider(color: _kBorder, height: 1),
          SizedBox(height: 12.h),
          _buildPaymentRow(
            'الإجمالي',
            IqdFormatter.format(total),
            isTotal: true,
          ),
          SizedBox(height: 20.h),
          // Pay Now button
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              final id = widget.auctionId ?? 'auction_fallback';
              context.push('/mazadat/payment/$id', extra: {
                'itemTitle': widget.itemTitle,
                'winningBid': widget.winningBid,
                'imageUrl': widget.imageUrl,
              });
            },
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(999.r),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'ادفع الآن',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Pay from wallet button
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _kCyan, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                'دفع من المحفظة',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: _kCyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String amount, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 15.sp : 13.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? _kTextPri : _kTextSec,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 18.sp : 13.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? _kCyan : _kTextPri,
          ),
        ),
      ],
    );
  }

  // ── Contact Seller Card ─────────────────────────────────────────────────
  Widget _buildContactSellerCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التواصل مع البائع',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: _kTextPri,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: _kCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: _kCyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message_rounded,
                            size: 18.sp, color: _kCyan),
                        SizedBox(width: 8.w),
                        Text(
                          'رسالة',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: _kCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => HapticFeedback.lightImpact(),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call_rounded,
                            size: 18.sp, color: _kTextSec),
                        SizedBox(width: 8.w),
                        Text(
                          'اتصال',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: _kTextSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Next Steps ──────────────────────────────────────────────────────────
  Widget _buildNextSteps() {
    final steps = [
      'أكمل الدفع خلال ٢٤ ساعة لتأكيد الشراء',
      'سيقوم البائع بشحن المنتج خلال ٤٨ ساعة',
      'استلم المنتج وتحقق من حالته',
      'قم بتأكيد الاستلام لتحرير المبلغ للبائع',
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخطوات التالية',
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: _kTextPri,
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 12.h : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kCyan.withValues(alpha: 0.1),
                      border: Border.all(
                          color: _kCyan.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: _kCyan,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: _kTextSec,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
