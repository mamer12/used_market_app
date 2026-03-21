import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/iqd_formatter.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';

// ── Mazadat Theme Constants ──────────────────────────────────────────────────
const _kBg        = Color(0xFF0A0A0F);
const _kSurface   = Color(0xFF12121A);
const _kBorder    = Color(0xFF1E1E2A);
const _kPrimary   = Color(0xFFFF3D5A);   // Mazadat red
const _kCyan      = Color(0xFF3CD2EB);   // bids / active accent
const _kEscrow    = Color(0xFF059669);   // escrow/completed green
const _kTextPri   = Colors.white;
const _kTextSec   = Color(0xFF9CA3AF);

// ── Mock data fallback ──────────────────────────────────────────────────────
final _mockActive = <_SellerAuction>[
  _SellerAuction(
    id: '1',
    title: 'آيفون 14 برو ماكس ١٢٨ جيجا',
    currentBid: 850000,
    bidderCount: 14,
    endTime: DateTime.now().add(const Duration(hours: 2, minutes: 34)),
    status: 'active',
  ),
  _SellerAuction(
    id: '2',
    title: 'لابتوب ديل XPS 15 كور i7',
    currentBid: 1200000,
    bidderCount: 7,
    endTime: DateTime.now().add(const Duration(minutes: 8)),
    status: 'active',
  ),
];

final _mockCompleted = <_SellerAuction>[
  _SellerAuction(
    id: '3',
    title: 'سامسونج S23 ألترا',
    currentBid: 980000,
    bidderCount: 22,
    endTime: DateTime.now().subtract(const Duration(days: 2)),
    status: 'ended',
    winnerName: 'محمد علي',
  ),
  _SellerAuction(
    id: '4',
    title: 'بلايستيشن 5 مع ذراعين',
    currentBid: 620000,
    bidderCount: 18,
    endTime: DateTime.now().subtract(const Duration(days: 5)),
    status: 'ended',
    winnerName: 'أحمد حسين',
  ),
];

final _mockDrafts = <_SellerAuction>[
  _SellerAuction(
    id: '5',
    title: 'كاميرا كانون EOS R6 مارك II',
    currentBid: 0,
    bidderCount: 0,
    endTime: DateTime.now(),
    status: 'draft',
  ),
  _SellerAuction(
    id: '6',
    title: 'ساعة ابل ووتش سيريس 9',
    currentBid: 0,
    bidderCount: 0,
    endTime: DateTime.now(),
    status: 'draft',
  ),
];

// ── Internal data model ──────────────────────────────────────────────────────
class _SellerAuction {
  final String id;
  final String title;
  final int currentBid;
  final int bidderCount;
  final DateTime endTime;
  final String status;
  final String? winnerName;

  const _SellerAuction({
    required this.id,
    required this.title,
    required this.currentBid,
    required this.bidderCount,
    required this.endTime,
    required this.status,
    this.winnerName,
  });

  bool get isUrgent {
    final remaining = endTime.difference(DateTime.now());
    return remaining.inMinutes < 15 && remaining.isNegative == false;
  }

  String get countdownLabel {
    final remaining = endTime.difference(DateTime.now());
    if (remaining.isNegative) return 'انتهى';
    if (remaining.inHours >= 1) return '${remaining.inHours}س ${remaining.inMinutes % 60}د';
    return '${remaining.inMinutes}د ${remaining.inSeconds % 60}ث';
  }

  String get completionDateLabel {
    return '${endTime.day}/${endTime.month}/${endTime.year}';
  }

  /// Convert from AuctionModel
  static _SellerAuction fromModel(AuctionModel m) => _SellerAuction(
        id: m.id ?? '',
        title: m.title,
        currentBid: m.currentPrice ?? m.startPrice ?? 0,
        bidderCount: 0,
        endTime: m.endTime ?? DateTime.now(),
        status: m.status,
      );
}

// ── Page ────────────────────────────────────────────────────────────────────

/// مزاداتي — Seller dashboard showing active / completed / draft auctions.
///
/// Stitch "My Auctions / Seller Dashboard" dark theme.
class MazadatAccountPage extends StatefulWidget {
  const MazadatAccountPage({super.key});

  @override
  State<MazadatAccountPage> createState() => _MazadatAccountPageState();
}

class _MazadatAccountPageState extends State<MazadatAccountPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Trigger BLoC load if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<AuctionsCubit>();
      cubit.loadAuctions();
      cubit.loadMyBids();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(context),
      body: BlocBuilder<AuctionsCubit, AuctionsState>(
        builder: (context, state) {
          final activeAuctions = state.auctions
              .where((a) => a.status == 'active' || a.status == 'live')
              .map(_SellerAuction.fromModel)
              .toList();
          final completedAuctions = state.auctions
              .where((a) => a.status == 'ended' || a.status == 'completed')
              .map(_SellerAuction.fromModel)
              .toList();

          final active    = activeAuctions.isNotEmpty    ? activeAuctions    : _mockActive;
          final completed = completedAuctions.isNotEmpty ? completedAuctions : _mockCompleted;
          final drafts    = _mockDrafts;

          final totalRevenue = completed.fold<int>(0, (sum, a) => sum + a.currentBid);

          return Column(
            children: [
              // ── Stats row ──────────────────────────────────────────
              _StatsRow(
                activeCount: active.length,
                completedCount: completed.length,
                revenue: totalRevenue,
              ),
              // ── TabBar ─────────────────────────────────────────────
              _buildTabBar(),
              // ── TabBarView ─────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ActiveTab(auctions: active, isLoading: state.isLoading),
                    _CompletedTab(auctions: completed, isLoading: state.isLoading),
                    _DraftsTab(drafts: drafts),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      // RTL: notification bell on the leading (right side in RTL = start)
      leading: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          margin: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: _kBg,
            shape: BoxShape.circle,
            border: Border.all(color: _kBorder),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 20.sp,
            color: _kTextSec,
          ),
        ),
      ),
      title: Text(
        'مزاداتي',
        style: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: _kTextPri,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _kSurface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: _kCyan,
        indicatorWeight: 2,
        labelColor: _kTextPri,
        unselectedLabelColor: _kTextSec,
        labelStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'نشطة'),
          Tab(text: 'مكتملة'),
          Tab(text: 'مسودات'),
        ],
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int activeCount;
  final int completedCount;
  final int revenue;

  const _StatsRow({
    required this.activeCount,
    required this.completedCount,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kSurface,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '$activeCount',
              label: 'النشطة',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              value: '$completedCount',
              label: 'المكتملة',
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _StatCard(
              value: IqdFormatter.compact(revenue),
              label: 'الإيرادات',
              valueSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final double? valueSize;

  const _StatCard({
    required this.value,
    required this.label,
    this.valueSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: valueSize ?? 20.sp,
              fontWeight: FontWeight.w700,
              color: _kCyan,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: _kTextSec,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active Tab ───────────────────────────────────────────────────────────────
class _ActiveTab extends StatelessWidget {
  final List<_SellerAuction> auctions;
  final bool isLoading;

  const _ActiveTab({required this.auctions, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kCyan),
      );
    }
    if (auctions.isEmpty) {
      return _EmptyState(
        icon: Icons.gavel_rounded,
        message: 'لا توجد مزادات نشطة حالياً',
        actionLabel: 'إنشاء مزاد',
        onAction: () => HapticFeedback.lightImpact(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: auctions.length,
      itemBuilder: (context, i) => _ActiveAuctionCard(auction: auctions[i]),
    );
  }
}

class _ActiveAuctionCard extends StatelessWidget {
  final _SellerAuction auction;

  const _ActiveAuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.image_rounded,
              color: _kTextSec,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPri,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Text(
                      IqdFormatter.format(auction.currentBid),
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _kCyan,
                      ),
                    ),
                    const Spacer(),
                    _CountdownPill(
                      label: auction.countdownLabel,
                      isUrgent: auction.isUrgent,
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 14.sp,
                      color: _kTextSec,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${auction.bidderCount} مزايد',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: _kTextSec,
                      ),
                    ),
                    const Spacer(),
                    _OutlinedSmallButton(
                      label: 'تعديل',
                      onTap: () => HapticFeedback.lightImpact(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completed Tab ────────────────────────────────────────────────────────────
class _CompletedTab extends StatelessWidget {
  final List<_SellerAuction> auctions;
  final bool isLoading;

  const _CompletedTab({required this.auctions, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kCyan),
      );
    }
    if (auctions.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline_rounded,
        message: 'لا توجد مزادات مكتملة بعد',
        actionLabel: 'استعراض المزادات',
        onAction: () => context.push('/mazadat'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: auctions.length,
      itemBuilder: (context, i) => _CompletedAuctionCard(auction: auctions[i]),
    );
  }
}

class _CompletedAuctionCard extends StatelessWidget {
  final _SellerAuction auction;

  const _CompletedAuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.image_rounded,
              color: _kTextSec,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPri,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'السعر النهائي: ',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: _kTextSec,
                      ),
                    ),
                    Text(
                      IqdFormatter.format(auction.currentBid),
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _kEscrow,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'تاريخ الإتمام: ${auction.completionDateLabel}',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: _kTextSec,
                  ),
                ),
                if (auction.winnerName != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'الفائز: ${auction.winnerName}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: _kTextSec,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _OutlinedSmallButton(
                    label: 'عرض التفاصيل',
                    onTap: () => HapticFeedback.lightImpact(),
                    color: _kEscrow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drafts Tab ────────────────────────────────────────────────────────────────
class _DraftsTab extends StatelessWidget {
  final List<_SellerAuction> drafts;

  const _DraftsTab({required this.drafts});

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return _EmptyState(
        icon: Icons.edit_note_rounded,
        message: 'لا توجد مسودات محفوظة',
        actionLabel: 'إنشاء مزاد جديد',
        onAction: () => HapticFeedback.lightImpact(),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: drafts.length,
      itemBuilder: (context, i) => _DraftCard(draft: drafts[i]),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final _SellerAuction draft;

  const _DraftCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: _kTextSec,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _kTextPri,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'كمل وانشر',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _kBorder),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'حذف',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: _kTextSec,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _CountdownPill extends StatelessWidget {
  final String label;
  final bool isUrgent;

  const _CountdownPill({required this.label, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    final bg    = isUrgent ? _kPrimary.withValues(alpha: 0.15) : _kCyan.withValues(alpha: 0.12);
    final color = isUrgent ? _kPrimary : _kCyan;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 12.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedSmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _OutlinedSmallButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? _kCyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          border: Border.all(color: c.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.sp, color: _kBorder),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              color: _kTextSec,
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                actionLabel,
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
}
