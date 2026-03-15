import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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

/// All-auctions list — two tabs: مباشر الآن / قريباً.
/// Ended auctions are never shown (filtered in AuctionsCubit).
class AuctionsPage extends StatefulWidget {
  const AuctionsPage({super.key});

  @override
  State<AuctionsPage> createState() => _AuctionsPageState();
}

class _AuctionsPageState extends State<AuctionsPage>
    with SingleTickerProviderStateMixin {
  late final AuctionsCubit _cubit;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionsCubit>()..loadAuctions();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      _cubit.setFilterStatus(['live', 'upcoming'][_tabCtrl.index]);
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
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) => [_buildAppBar()],
          body: BlocBuilder<AuctionsCubit, AuctionsState>(
            builder: (context, state) {
              if (state.isLoading && state.auctions.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.mazadGreen,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state.error != null && state.auctions.isEmpty) {
                return _buildError(state.error!);
              }

              final auctions = state.auctions;
              return Column(
                children: [
                  _buildSortBar(state),
                  Expanded(
                    child: auctions.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            color: AppTheme.mazadGreen,
                            onRefresh: _cubit.loadAuctions,
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                  16.w, 12.h, 16.w, 100.h),
                              itemCount: auctions.length +
                                  (state.isLoading ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (_, i) {
                                if (i == auctions.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.h),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: AppTheme.mazadGreen,
                                          strokeWidth: 2),
                                    ),
                                  );
                                }
                                return _AuctionCard(auction: auctions[i]);
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
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'المزادات',
        style: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(44.h),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.divider)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppTheme.mazadGreen,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.textPrimary,
            unselectedLabelColor: AppTheme.textTertiary,
            labelStyle: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'مباشر الآن'),
              Tab(text: 'قريباً'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBar(AuctionsState state) {
    const options = [
      ('ending_soon', 'ينتهي قريباً'),
      ('price_asc', 'الأقل سعراً'),
      ('price_desc', 'الأعلى سعراً'),
      ('newest', 'الأحدث'),
    ];
    return SizedBox(
      height: 44.h,
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
              _cubit.setSortBy(options[i].$1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.mazadGreen.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: selected
                      ? AppTheme.mazadGreen
                      : AppTheme.divider,
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
            decoration: BoxDecoration(
              color: AppTheme.mazadGreen.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gavel_rounded,
                size: 32.sp, color: AppTheme.mazadGreen),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد مزادات نشطة',
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'تحقق لاحقاً',
            style: GoogleFonts.cairo(
                fontSize: 13.sp, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 40.sp, color: AppTheme.textTertiary),
          SizedBox(height: 12.h),
          Text(
            'تعذر التحميل',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: _cubit.loadAuctions,
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.mazadGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auction Card ──────────────────────────────────────────────────────────────

class _AuctionCard extends StatefulWidget {
  final AuctionModel auction;
  const _AuctionCard({required this.auction});

  @override
  State<_AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<_AuctionCard> {
  Timer? _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
  }

  void _tick() {
    final end = widget.auction.endTime;
    if (end == null) return;
    _secondsLeft = end.difference(DateTime.now()).inSeconds.clamp(0, 999999);
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
  bool get _isLive => widget.auction.status == 'live' ||
      widget.auction.status == 'active';

  @override
  Widget build(BuildContext context) {
    final item = widget.auction;
    final price = item.currentPrice ?? item.startPrice ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AuctionLivePage(
            auctionId: item.id ?? '',
            title: item.title,
            currentPrice: '$price',
            currency: 'د.ع',
            imageUrl: item.images.isNotEmpty
                ? item.images.first
                : 'https://placehold.co/400x400/png',
          ),
        ));
      },
      child: Container(
        decoration: AppTheme.cardElevatedDecoration,
        clipBehavior: Clip.antiAlias,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────────────
            SizedBox(
              width: 104.w,
              height: 120.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.images.isNotEmpty
                        ? item.images.first
                        : 'https://placehold.co/400x400/png',
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: AppTheme.shimmerBase,
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.shimmerBase,
                      child: Icon(Icons.image_outlined,
                          color: AppTheme.shimmerHighlight, size: 28.sp),
                    ),
                  ),
                  // LIVE badge
                  if (_isLive)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: _LiveBadge(),
                    ),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6.h),

                    // Category chip
                    if (item.category != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          item.category!,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.mazadGreen,
                          ),
                        ),
                      ),

                    SizedBox(height: 10.h),

                    // Price + Timer
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                  fontSize: 15.sp,
                                  color: AppTheme.mazadGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Countdown pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _isUrgent
                                ? AppTheme.mazadGreen.withValues(alpha: 0.12)
                                : AppTheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                              color: _isUrgent
                                  ? AppTheme.mazadGreen
                                  : AppTheme.divider,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 11.sp,
                                color: _isUrgent
                                    ? AppTheme.mazadGreen
                                    : AppTheme.textTertiary,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                _timeLabel,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
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
                  ],
                ),
              ),
            ),

            // ── Chevron ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: AppTheme.textTertiary,
                    size: 20.sp,
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

// ── Live badge with pulsing dot ───────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fade = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fade,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.mazadGreen,
              ),
            ),
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
    );
  }
}
