import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';

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

    // Mock initial bids
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
      backgroundColor: const Color(0xFF140F23),
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
            color: const Color(0xFF140F23).withValues(alpha: 0.8),
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
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppTheme.mazadRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.mazadRed,
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
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 20,
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 70.h),
          _buildAuctionItemCard(),
          _buildCountdownSection(),
          _buildBidHistory(),
          SizedBox(height: 180.h), // Footer spacing
        ],
      ),
    );
  }

  Widget _buildAuctionItemCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
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
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'أعلى مزايدة حالية',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  IqdFormatter.format(_currentBid),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
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
            color: AppTheme.mazadRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppTheme.mazadRed.withValues(
                alpha: 0.2 + (_glowController.value * 0.3),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.mazadRed.withValues(
                  alpha: 0.1 * _glowController.value,
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
                  color: AppTheme.mazadRed,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '02:45:12',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: AppTheme.mazadRed.withValues(
                        alpha: 0.5 * _glowController.value,
                      ),
                      blurRadius: 10,
                    ),
                  ],
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
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل المزايدات',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bids.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white.withValues(alpha: 0.05),
              height: 24.h,
            ),
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
                          ? AppTheme.primary
                          : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isMe
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      size: 16.sp,
                      color: isMe ? Colors.black : Colors.white,
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
                            color: isMe ? AppTheme.primary : Colors.white,
                          ),
                        ),
                        Text(
                          bid['time'],
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    IqdFormatter.format(bid['amount']),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
      decoration: BoxDecoration(
        color: const Color(0xFF140F23).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildIncrementButton('+250k', 250000),
              SizedBox(width: 8.w),
              _buildIncrementButton('+500k', 500000),
              SizedBox(width: 8.w),
              _buildIncrementButton('+1M', 1000000),
            ],
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _placeBid(250000),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mazadRed,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              shadowColor: AppTheme.mazadRed.withValues(alpha: 0.4),
              elevation: 8,
            ),
            child: Text(
              'زايد الآن',
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
