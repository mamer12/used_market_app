import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../data/models/feed_models.dart';
import '../bloc/feed_cubit.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late final FeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<FeedCubit>()..loadFeed();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: BlocBuilder<FeedCubit, FeedState>(
          builder: (context, state) {
            if (state.isLoading && state.items.isEmpty) {
              return const _FeedSkeleton();
            }
            if (state.error != null && state.items.isEmpty) {
              return _ErrorView(
                message: state.error!,
                onRetry: _cubit.loadFeed,
              );
            }
            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: AppTheme.primary,
              strokeWidth: 2.5,
              onRefresh: () async {
                await HapticFeedback.mediumImpact();
                await _cubit.loadFeed();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _FeedHeader(personalized: state.personalized)),
                  if (state.items.isEmpty)
                    const SliverFillRemaining(child: _EmptyView())
                  else
                    SliverPadding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 110.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = state.items[index];
                            return _FeedCard(
                              item: item,
                              onVisible: () => _cubit.trackView(item),
                            );
                          },
                          childCount: state.items.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _FeedHeader extends StatelessWidget {
  final bool personalized;
  const _FeedHeader({required this.personalized});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, topPadding + 12.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لك',
            style: GoogleFonts.cairo(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            personalized
                ? 'مختار خصيصاً بناءً على اهتماماتك'
                : 'الأكثر رواجاً الآن',
            style: GoogleFonts.tajawal(
              fontSize: 13.sp,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feed Card ─────────────────────────────────────────────────────────────

class _FeedCard extends StatefulWidget {
  final FeedItem item;
  final VoidCallback onVisible;

  const _FeedCard({required this.item, required this.onVisible});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _tracked = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isAuction = item.kind == 'auction';
    final imageUrl = item.images.isNotEmpty
        ? item.images.first
        : 'https://placehold.co/400x400/png';

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (_) {
        _maybeTrack();
        return false;
      },
      child: GestureDetector(
        onTap: _maybeTrack,
        child: Container(
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: Image.network(
                  imageUrl,
                  width: 110.w,
                  height: 110.w,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, st) => Container(
                    width: 110.w,
                    height: 110.w,
                    color: AppTheme.surfaceAlt,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: AppTheme.inactive, size: 28.sp),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Details
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 12.h, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge row
                      Row(
                        children: [
                          _KindBadge(isAuction: isAuction),
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              item.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.tajawal(
                                fontSize: 11.sp,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        IqdFormatter.format(item.price.toDouble()),
                        style: GoogleFonts.tajawal(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                        ),
                      ),
                      if (isAuction && item.endTime != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 12.sp, color: AppTheme.textSecondary),
                            SizedBox(width: 4.w),
                            Text(
                              _formatEndTime(item.endTime!),
                              style: GoogleFonts.tajawal(
                                fontSize: 11.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeTrack() {
    if (!_tracked) {
      _tracked = true;
      widget.onVisible();
    }
  }

  String _formatEndTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final diff = dt.difference(DateTime.now());
      if (diff.isNegative) return 'انتهى';
      if (diff.inHours < 1) return 'ينتهي خلال ${diff.inMinutes} د';
      if (diff.inDays < 1) return 'ينتهي خلال ${diff.inHours} س';
      return 'ينتهي خلال ${diff.inDays} ي';
    } catch (_) {
      return '';
    }
  }
}

// ── Kind Badge ────────────────────────────────────────────────────────────

class _KindBadge extends StatelessWidget {
  final bool isAuction;
  const _KindBadge({required this.isAuction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isAuction
            ? AppTheme.liveBadge.withValues(alpha: 0.12)
            : AppTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        isAuction ? 'مزاد' : 'منتج',
        style: GoogleFonts.tajawal(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: isAuction ? AppTheme.liveBadge : AppTheme.primary,
        ),
      ),
    );
  }
}

// ── Empty View ────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 64.sp, color: AppTheme.inactive),
            SizedBox(height: 16.h),
            Text(
              'ابدأ بتصفح المنتجات لنخصص لك تجربتك',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'سنقترح لك أفضل المنتجات والمزادات بناءً على تصفحك',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56.sp, color: AppTheme.inactive),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                  fontSize: 15.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────

class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: List.generate(
            6,
            (_) => Container(
              margin: EdgeInsets.only(bottom: 14.h),
              child: Row(
                children: [
                  SkeletonBox(width: 110.w, height: 110.w, borderRadius: 16.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 60.w, height: 16.h, borderRadius: 6.r),
                        SizedBox(height: 8.h),
                        SkeletonBox(width: double.infinity, height: 14.h, borderRadius: 4.r),
                        SizedBox(height: 4.h),
                        SkeletonBox(width: 180.w, height: 14.h, borderRadius: 4.r),
                        SizedBox(height: 10.h),
                        SkeletonBox(width: 80.w, height: 18.h, borderRadius: 4.r),
                      ],
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
}
