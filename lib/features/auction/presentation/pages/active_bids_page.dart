import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';

/// مزايداتي — Mazadat My Auctions Dashboard.
///
/// 4-stat header + TabBar (جارية / منتهية / فائزة) + bid list.
///
/// Based on Stitch v2 Screen "Mazadat My Auctions Dashboard".
class ActiveBidsPage extends StatefulWidget {
  const ActiveBidsPage({super.key});

  @override
  State<ActiveBidsPage> createState() => _ActiveBidsPageState();
}

class _ActiveBidsPageState extends State<ActiveBidsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['جارية', 'منتهية', 'فائزة', 'الكل'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<AuctionsCubit>().loadMyBids();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuctionsCubit, AuctionsState>(
      builder: (context, state) {
        final bids = state.myBids;
        final wonCount = bids.length ~/ 3; // mock ratio until API provides status
        final activeCount = bids.length - wonCount;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: _DashboardHeader(
                  totalBids: bids.length,
                  activeBids: activeCount,
                  wonBids: wonCount,
                  totalSpent: bids.fold<double>(
                    0,
                    (sum, b) => sum + b.amount,
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    labelColor: AppTheme.mazadGreen,
                    unselectedLabelColor: Colors.white38,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppTheme.mazadGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.white12,
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // جارية — Active bids (mocked as first half)
                _BidsList(
                  bids: bids.take(activeCount).toList(),
                  isLoading: state.isLoadingMyBids,
                  emptyLabel: 'لا توجد مزايدات جارية',
                  statusLabel: 'جارية',
                  statusColor: const Color(0xFF00F5FF),
                ),
                // منتهية — Ended bids
                _BidsList(
                  bids: bids.skip(activeCount).take(wonCount).toList(),
                  isLoading: state.isLoadingMyBids,
                  emptyLabel: 'لا توجد مزايدات منتهية',
                  statusLabel: 'منتهية',
                  statusColor: Colors.white38,
                ),
                // فائزة — Won bids
                _BidsList(
                  bids: bids.skip(bids.length - wonCount).toList(),
                  isLoading: state.isLoadingMyBids,
                  emptyLabel: 'لا توجد مزايدات فائزة',
                  statusLabel: 'فائزة',
                  statusColor: AppTheme.mazadGreen,
                ),
                // الكل — All bids
                _BidsList(
                  bids: bids,
                  isLoading: state.isLoadingMyBids,
                  emptyLabel: 'لا توجد مزايدات',
                  statusLabel: 'قيد الانتظار',
                  statusColor: Colors.white38,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Dashboard Header ────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final int totalBids;
  final int activeBids;
  final int wonBids;
  final double totalSpent;

  const _DashboardHeader({
    required this.totalBids,
    required this.activeBids,
    required this.wonBids,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة مزايداتي',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          // 4-stat grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'إجمالي المزايدات',
                  value: '$totalBids',
                  icon: Icons.gavel_rounded,
                  color: const Color(0xFF00F5FF),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'مزايدات جارية',
                  value: '$activeBids',
                  icon: Icons.timer_rounded,
                  color: const Color(0xFFFF3D5A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'مزايدات فائزة',
                  value: '$wonBids',
                  icon: Icons.emoji_events_rounded,
                  color: AppTheme.mazadGreen,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'إجمالي الإنفاق',
                  value: IqdFormatter.format(totalSpent),
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFFFFB800),
                  smallValue: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool smallValue;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.smallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: smallValue ? 14.sp : 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bids List ────────────────────────────────────────────────────────────────

class _BidsList extends StatelessWidget {
  final List<BidModel> bids;
  final bool isLoading;
  final String emptyLabel;
  final String statusLabel;
  final Color statusColor;

  const _BidsList({
    required this.bids,
    required this.isLoading,
    required this.emptyLabel,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && bids.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.mazadGreen),
      );
    }

    if (bids.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, color: Colors.white24, size: 56.sp),
            SizedBox(height: 16.h),
            Text(
              emptyLabel,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بالمزايدة على عناصر جديدة',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: Colors.white38,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/mazadat');
              },
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  'تصفح المزادات',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
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

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      itemCount: bids.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) => _BidCard(
        bid: bids[index],
        statusLabel: statusLabel,
        statusColor: statusColor,
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final BidModel bid;
  final String statusLabel;
  final Color statusColor;

  const _BidCard({
    required this.bid,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: CachedNetworkImage(
                imageUrl: 'https://placehold.co/400x400/1a1a2e/white?text=مزاد',
                width: 76.w,
                height: 76.w,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: const Color(0xFF1E1E2A)),
                errorWidget: (_, _, _) =>
                    Container(color: const Color(0xFF1E1E2A),
                      child: Icon(Icons.gavel_rounded,
                          color: Colors.white24, size: 28.sp)),
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
                        child: Text(
                          bid.auctionId ?? 'مزاد #${bid.id.substring(0, 6)}',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'منذ قليل',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مزايدتك',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: Colors.white38,
                            ),
                          ),
                          Text(
                            IqdFormatter.format(bid.amount.toDouble()),
                            style: AppTheme.priceStyle(
                              fontSize: 15.sp,
                              color: AppTheme.mazadGreen,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white24,
                        size: 14.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Bar Delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
