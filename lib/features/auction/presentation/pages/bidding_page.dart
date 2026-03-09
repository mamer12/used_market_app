import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

/// Alternative bidding page — warm theme.
class BiddingPage extends StatefulWidget {
  final String auctionId;
  final String imageUrl;
  final String title;
  final double initialPrice;

  const BiddingPage({
    super.key,
    required this.auctionId,
    required this.imageUrl,
    required this.title,
    required this.initialPrice,
  });

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage>
    with TickerProviderStateMixin {
  late double _currentBid;
  final List<Map<String, dynamic>> _bids = [];
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _currentBid = widget.initialPrice;
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bids.addAll([
      {
        'name': 'أحمد محمد',
        'amount': widget.initialPrice - 500000,
        'time': 'منذ 5 دقائق',
      },
      {
        'name': 'سجاد علي',
        'amount': widget.initialPrice - 250000,
        'time': 'منذ دقيقتين',
      },
    ]);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _placeBid(double increment) {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentBid += increment;
      _bids.insert(0, {
        'name': 'أنت',
        'amount': _currentBid,
        'time': 'الآن',
        'isMe': true,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(children: [_buildContent(), _buildHeader()]),
      bottomNavigationBar: _buildBottomControls(context),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8.h,
              bottom: 8.h,
            ),
            color: AppTheme.background.withValues(alpha: 0.85),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: AppTheme.textPrimary),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: AppTheme.mazadGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.mazadGreen.withValues(alpha: 0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'المزاد المباشر',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share_outlined,
                        color: AppTheme.textPrimary, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 70.h),
          _buildAuctionItemCard(),
          _buildCountdownSection(),
          _buildBidHistory(),
          SizedBox(height: 180.h),
        ],
      ),
    );
  }

  Widget _buildAuctionItemCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'أعلى مزايدة حالية',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
                Text(
                  IqdFormatter.format(_currentBid),
                  style: AppTheme.priceStyle(
                    fontSize: 18.sp,
                    color: AppTheme.mazadGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(vertical: 24.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.mazadGreenSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.mazadGreen.withValues(
                alpha: 0.15 + (_glowController.value * 0.2),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.mazadGreen.withValues(
                  alpha: 0.06 * _glowController.value,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'الوقت المتبقي',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mazadGreen,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '02:45:12',
                style: AppTheme.priceStyle(
                  fontSize: 48.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBidHistory() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل المزايدات',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bids.length,
            separatorBuilder: (context, index) =>
                Divider(color: AppTheme.divider, height: 24.h),
            itemBuilder: (context, index) {
              final bid = _bids[index];
              final isMe = bid['isMe'] == true;
              return Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.mazadGreen.withValues(alpha: 0.2)
                          : AppTheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMe
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      size: 16.sp,
                      color: isMe ? AppTheme.mazadGreen : AppTheme.textTertiary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bid['name'],
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? AppTheme.mazadGreen
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          bid['time'],
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    IqdFormatter.format(bid['amount']),
                    style: AppTheme.priceStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceAlt,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildIncrementButton('+250K', 250000),
              SizedBox(width: 8.w),
              _buildIncrementButton('+500K', 500000),
              SizedBox(width: 8.w),
              _buildIncrementButton('+1M', 1000000),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _placeBid(250000),
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mazadGreen.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'زايد الآن',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementButton(String label, double increment) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _placeBid(increment),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: AppTheme.divider),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
