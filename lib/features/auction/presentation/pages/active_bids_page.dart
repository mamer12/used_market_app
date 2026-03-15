import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../bloc/auctions_cubit.dart';

/// Bid History / Active Bids page — "سجل المزايدات".
///
/// Stats grid + filter chips + detailed bid cards with image/status.
///
/// Based on Stitch Screen 2 (5fe820f6).
class ActiveBidsPage extends StatefulWidget {
  const ActiveBidsPage({super.key});

  @override
  State<ActiveBidsPage> createState() => _ActiveBidsPageState();
}

class _ActiveBidsPageState extends State<ActiveBidsPage> {
  int _selectedFilter = 0;

  static const _filters = ['الكل', 'فائز', 'خاسر', 'قيد الانتظار'];

  @override
  void initState() {
    super.initState();
    // Load my bids once the tab is visited. (Safe to call repeatedly, Cubit can dedup if doing heavy work, though loadMyBids doesn't yet).
    context.read<AuctionsCubit>().loadMyBids();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuctionsCubit, AuctionsState>(builder: (context, state) {
      final allBids = state.myBids;
      final wonBids = allBids.where((b) => b.auctionId != null).toList(); // simplified check since BidModel doesn't have status yet
      
      final filteredBids = allBids;
      
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    SizedBox(height: 8.h),
                    _buildStatsGrid(allBids.length, wonBids.length),
                    SizedBox(height: 20.h),
                    _buildFilterChips(),
                    SizedBox(height: 16.h),
                    if (state.isLoadingMyBids)
                      const Center(child: CircularProgressIndicator(color: AppTheme.mazadGreen))
                    else if (filteredBids.isEmpty)
                      _buildEmptyBids()
                    else
                      ..._buildBidCards(filteredBids),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyBids() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 48.h),
        Icon(Icons.history_rounded, color: Colors.white24, size: 64.sp),
        SizedBox(height: 16.h),
        Text(
          'لا توجد مزايدات',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Nav header removed; MazadatShell uses common top AppBar. If we need back button, adding it:
          SizedBox(width: 40.w), // spacing
          Expanded(
            child: Text(
              'سجل المزايدات',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  // ── Stats Grid (Stitch Screen 2) ──────────────────────────────────────────
  Widget _buildStatsGrid(int total, int won) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Text(
                  'إجمالي المزايدات',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: Colors.white54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$total',
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.mazadGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'المزادات الفائزة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: Colors.white54,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$won',
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Filter Chips ──────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isActive = _selectedFilter == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.mazadGreen : const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: isActive ? AppTheme.mazadGreen : Colors.white12,
                ),
              ),
              child: Text(
                _filters[index],
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bid Cards ─────────────────────────────────────────────────────────────
  List<Widget> _buildBidCards(List<dynamic> bids) {
    return bids.map((bid) {
      final isWon = false; // BidModel needs robust status parsing depending on real API
      final isLost = false;

      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Opacity(
          opacity: isLost ? 0.8 : 1.0,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF12121A),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: CachedNetworkImage(
                    imageUrl: 'https://placehold.co/400x400',
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    color: isLost ? Colors.grey : null,
                    colorBlendMode: isLost ? BlendMode.saturation : null,
                    placeholder: (_, _) => Container(color: Colors.white10),
                    errorWidget: (_, _, _) => Container(color: Colors.white10),
                  ),
                ),
                SizedBox(width: 12.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bid.auctionId ?? 'عنصر',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'الان',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isWon
                                  ? AppTheme.mazadGreen.withValues(alpha: 0.15)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              isWon ? 'فائز' : 'قيد الانتظار',
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: isWon ? AppTheme.mazadGreen : Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Bottom row: price + action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مزايدتك الأخيرة',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: Colors.white54,
                                ),
                              ),
                              Text(
                                IqdFormatter.format(bid.amount.toDouble()),
                                style: AppTheme.priceStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          if (isWon)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/mazadat/payment/${bid.auctionId}', extra: {
                                  'winningBid': bid.amount,
                                  'itemTitle': bid.auctionId ?? '',
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'التفاصيل',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.mazadGreen,
                                    ),
                                  ),
                                  Icon(Icons.chevron_left_rounded,
                                      color: AppTheme.mazadGreen, size: 18.sp),
                                ],
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
