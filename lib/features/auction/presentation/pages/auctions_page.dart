import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../data/models/auction_models.dart';
import 'auction_live_page.dart';

class AuctionsPage extends StatefulWidget {
  const AuctionsPage({super.key});

  @override
  State<AuctionsPage> createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage>
    with SingleTickerProviderStateMixin {
  late final HomeCubit _homeCubit;
  late final TabController _tabCtrl;

  // Filter state
  String _sortBy =
      'ending_soon'; // ending_soon | price_asc | price_desc | newest
  String _filterStatus = 'live'; // live | upcoming | ended

  @override
  void initState() {
    super.initState();
    _homeCubit = getIt<HomeCubit>()..loadFeed();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      setState(() {
        _filterStatus = ['live', 'upcoming', 'ended'][_tabCtrl.index];
      });
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeCubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [_buildAppBar()],
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }
              final auctions = state.liveAuctions;
              final filtered = _applyFilters(auctions);

              return Column(
                children: [
                  _buildStats(auctions),
                  _buildSortBar(),
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: AppTheme.primary,
                            onRefresh: () async => _homeCubit.loadFeed(),
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                8.h,
                                16.w,
                                100.h,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 14.h),
                              itemBuilder: (context, i) =>
                                  _AuctionTile(auction: filtered[i]),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0D0D),
      expandedHeight: 140.h,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🔨', style: TextStyle(fontSize: 22.sp)),
                      SizedBox(width: 8.w),
                      Text(
                        'المزادات الحية',
                        style: GoogleFonts.cairo(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Live Auctions',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(46.h),
        child: Container(
          color: const Color(0xFF0D0D0D),
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'مباشر الآن'),
              Tab(text: 'قريباً'),
              Tab(text: 'انتهى'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(List<AuctionModel> all) {
    final live = all.where((a) => a.status == 'live').length;
    return Container(
      color: const Color(0xFF0D0D0D),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      child: Row(
        children: [
          _StatBadge(
            icon: Icons.sensors_rounded,
            label: '$live مزاد مباشر',
            color: AppTheme.liveBadge,
          ),
          SizedBox(width: 10.w),
          _StatBadge(
            icon: Icons.people_rounded,
            label: '${all.length * 24} مشاهد',
            color: const Color(0xFF5AC8FA),
          ),
          SizedBox(width: 10.w),
          _StatBadge(
            icon: Icons.gavel_rounded,
            label: '${all.length * 7} مزايدة',
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    final options = [
      ('ending_soon', 'ينتهي قريباً'),
      ('price_asc', 'الأقل سعراً'),
      ('price_desc', 'الأعلى سعراً'),
      ('newest', 'الأحدث'),
    ];
    return Container(
      height: 44.h,
      color: AppTheme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final selected = _sortBy == options[i].$1;
          return GestureDetector(
            onTap: () => setState(() => _sortBy = options[i].$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? AppTheme.primary : Colors.grey[300]!,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                options[i].$2,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<AuctionModel> _applyFilters(List<AuctionModel> auctions) {
    final list = auctions.where((a) {
      if (_filterStatus == 'live') return a.status == 'live';
      if (_filterStatus == 'upcoming') return a.status == 'upcoming';
      if (_filterStatus == 'ended') return a.status == 'ended';
      return true;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort(
          (a, b) => (a.currentPrice ?? 0).compareTo(b.currentPrice ?? 0),
        );
      case 'price_desc':
        list.sort(
          (a, b) => (b.currentPrice ?? 0).compareTo(a.currentPrice ?? 0),
        );
      case 'newest':
        list.sort((a, b) => (b.id ?? '').compareTo(a.id ?? ''));
      default: // ending_soon
        list.sort(
          (a, b) => (a.endTime ?? DateTime(9999)).compareTo(
            b.endTime ?? DateTime(9999),
          ),
        );
    }
    return list;
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔨', style: TextStyle(fontSize: 56.sp)),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مزادات حالياً',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            'تحقق لاحقاً',
            style: GoogleFonts.cairo(fontSize: 13.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── Auction Tile ─────────────────────────────────────────────────────────────

class _AuctionTile extends StatefulWidget {
  final AuctionModel auction;

  const _AuctionTile({required this.auction});

  @override
  State<_AuctionTile> createState() => _AuctionTileState();
}

class _AuctionTileState extends State<_AuctionTile> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_updateTimer);
    });
  }

  void _updateTimer() {
    final end = widget.auction.endTime;
    if (end == null) return;
    final diff = end.difference(DateTime.now()).inSeconds;
    _secondsLeft = diff.clamp(0, 999999);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    if (_secondsLeft <= 0) return 'انتهى';
    final h = _secondsLeft ~/ 3600;
    final m = (_secondsLeft % 3600) ~/ 60;
    final s = _secondsLeft % 60;
    if (h > 0) return '$hس $mد';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get _isUrgent => _secondsLeft > 0 && _secondsLeft < 120;

  String _fmt(int n) {
    final str = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.auction;
    final price = item.currentPrice ?? item.startPrice ?? 0;
    final isLive = item.status == 'live';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AuctionLivePage(
              auctionId: item.id ?? '',
              title: item.title,
              currentPrice: '${item.currentPrice ?? 0}',
              currency: 'IQD',
              imageUrl: item.images.isNotEmpty
                  ? item.images.first
                  : 'https://placehold.co/400x400/png',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: 110.w,
              height: 110.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.images.isNotEmpty
                        ? item.images.first
                        : 'https://placehold.co/400x400/1A1A1A/888888/png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF1A1A1A),
                      child: Icon(
                        Icons.image_rounded,
                        color: Colors.grey[700],
                        size: 32.sp,
                      ),
                    ),
                  ),
                  // Live indicator
                  if (isLive)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.liveBadge,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'LIVE',
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),

                    // Category chip
                    if (item.category != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item.category!,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    SizedBox(height: 8.h),

                    // Price row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أعلى مزايدة',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                '${_fmt(price)} IQD',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Countdown
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isUrgent
                                ? const Color(
                                    0xFFFF3B30,
                                  ).withValues(alpha: 0.10)
                                : const Color(
                                    0xFF1A1A1A,
                                  ).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: _isUrgent
                                  ? const Color(
                                      0xFFFF3B30,
                                    ).withValues(alpha: 0.25)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 12.sp,
                                color: _isUrgent
                                    ? const Color(0xFFFF3B30)
                                    : Colors.grey[600],
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _timeLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _isUrgent
                                      ? const Color(0xFFFF3B30)
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Bid Now button
                    SizedBox(
                      width: double.infinity,
                      height: 32.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AuctionLivePage(
                                auctionId: item.id ?? '',
                                title: item.title,
                                currentPrice: '$price',
                                currency: 'IQD',
                                imageUrl: item.images.isNotEmpty
                                    ? item.images.first
                                    : 'https://placehold.co/400x400/png',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.gavel_rounded, size: 14.sp),
                        label: Text(
                          'زايد الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Badge ───────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
