import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';
import 'auction_live_page.dart';

/// Auctions list with tabs (مباشر / قريباً / انتهى) — warm theme.
class AuctionsPage extends StatefulWidget {
  const AuctionsPage({super.key});

  @override
  State<AuctionsPage> createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage>
    with SingleTickerProviderStateMixin {
  late final AuctionsCubit _auctionsCubit;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _auctionsCubit = getIt<AuctionsCubit>()..loadAuctions();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      final status = ['live', 'upcoming', 'ended'][_tabCtrl.index];
      _auctionsCubit.setFilterStatus(status);
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
      value: _auctionsCubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [_buildAppBar()],
          body: BlocBuilder<AuctionsCubit, AuctionsState>(
            builder: (context, state) {
              if (state.isLoading && state.auctions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.mazadGreen),
                );
              }
              final auctions = state.auctions;
              return Column(
                children: [
                  _buildStats(auctions),
                  _buildSortBar(state),
                  Expanded(
                    child: auctions.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: AppTheme.mazadGreen,
                            onRefresh: () async =>
                                _auctionsCubit.loadAuctions(),
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                  16.w, 8.h, 16.w, 100.h),
                              itemCount: auctions.length +
                                  (state.isLoading ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 14.h),
                              itemBuilder: (context, i) {
                                if (i == auctions.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: AppTheme.mazadGreen),
                                  );
                                }
                                return _AuctionTile(auction: auctions[i]);
                              },
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
      backgroundColor: AppTheme.background,
      expandedHeight: 120.h,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
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
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  'تصفح جميع المزادات',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(46.h),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.divider)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppTheme.mazadGreen,
            indicatorWeight: 3,
            labelColor: AppTheme.mazadGreen,
            unselectedLabelColor: AppTheme.textTertiary,
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
      color: AppTheme.surface,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      child: Row(
        children: [
          _StatBadge(
            icon: Icons.sensors_rounded,
            label: '$live مزاد مباشر',
            color: AppTheme.mazadGreen,
          ),
          SizedBox(width: 10.w),
          _StatBadge(
            icon: Icons.people_rounded,
            label: '${all.length * 24} مشاهد',
            color: AppTheme.matajirBlue,
          ),
          SizedBox(width: 10.w),
          _StatBadge(
            icon: Icons.gavel_rounded,
            label: '${all.length * 7} مزايدة',
            color: AppTheme.mazadGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar(AuctionsState state) {
    final options = [
      ('ending_soon', 'ينتهي قريباً'),
      ('price_asc', 'الأقل سعراً'),
      ('price_desc', 'الأعلى سعراً'),
      ('newest', 'الأحدث'),
    ];
    return Container(
      height: 44.h,
      color: AppTheme.background,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        itemCount: options.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final selected = state.sortBy == options[i].$1;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _auctionsCubit.setSortBy(options[i].$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: selected ? AppTheme.mazadGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: selected ? AppTheme.mazadGreen : AppTheme.divider,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                options[i].$2,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gavel_rounded,
                size: 36.sp, color: AppTheme.textTertiary),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مزادات حالياً',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            'تحقق لاحقاً',
            style: GoogleFonts.cairo(
                fontSize: 13.sp, color: AppTheme.textTertiary),
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

  @override
  Widget build(BuildContext context) {
    final item = widget.auction;
    final price = item.currentPrice ?? item.startPrice ?? 0;
    final isLive = item.status == 'live';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AuctionLivePage(
              auctionId: item.id ?? '',
              title: item.title,
              currentPrice: '$price',
              currency: 'د.ع',
              imageUrl: item.images.isNotEmpty
                  ? item.images.first
                  : 'https://placehold.co/400x400/png',
            ),
          ),
        );
      },
      child: Container(
        decoration: AppTheme.cardElevatedDecoration,
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              width: 110.w,
              height: 130.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.images.isNotEmpty
                        ? item.images.first
                        : 'https://placehold.co/400x400/png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppTheme.shimmerBase,
                      child: Icon(Icons.image_rounded,
                          color: AppTheme.shimmerHighlight, size: 32.sp),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppTheme.mazadGreen,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'مباشر',
                              style: GoogleFonts.cairo(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
                    Text(
                      item.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    if (item.category != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          item.category!,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondary,
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
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                              Text(
                                IqdFormatter.format(price.toDouble()),
                                style: AppTheme.priceStyle(
                                  fontSize: 16.sp,
                                  color: AppTheme.mazadGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Countdown
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: _isUrgent
                                ? AppTheme.mazadGreenSurface
                                : AppTheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: _isUrgent
                                  ? AppTheme.mazadGreen.withValues(alpha: 0.3)
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
                                    ? AppTheme.mazadGreen
                                    : AppTheme.textTertiary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                _timeLabel,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _isUrgent
                                      ? AppTheme.mazadGreen
                                      : AppTheme.textSecondary,
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
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AuctionLivePage(
                                auctionId: item.id ?? '',
                                title: item.title,
                                currentPrice: '$price',
                                currency: 'د.ع',
                                imageUrl: item.images.isNotEmpty
                                    ? item.images.first
                                    : 'https://placehold.co/400x400/png',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mazadGreen,
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
