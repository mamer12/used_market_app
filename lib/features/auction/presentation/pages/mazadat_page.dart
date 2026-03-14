import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';
import 'auction_live_page.dart';
import 'mazadat_account_page.dart';
import 'mazadat_watchlist_page.dart';
import '../../../home/data/models/portal_models.dart';
import '../../../home/presentation/widgets/home_components.dart';

/// مزادات — Auctions marketplace hub.
///
/// Warm "Iraqi Bazaar Modernism" design with featured banner,
/// category chips, and large auction cards.
///
/// Based on Stitch Screen 8 (953e87ff).
class MazadatPage extends StatefulWidget {
  const MazadatPage({super.key});

  @override
  State<MazadatPage> createState() => _MazadatPageState();
}

class _MazadatPageState extends State<MazadatPage> {
  late final AuctionsCubit _cubit;
  late final CategoryCubit _categoryCubit;
  int _selectedNavIndex = 0;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AuctionsCubit>()..loadAuctions();
    _categoryCubit = getIt<CategoryCubit>(param1: 'mazadat')..fetchCategories();
  }

  /// Maps bottom nav index to IndexedStack index.
  /// Nav: 0=Home, 1=Watchlist, 2=FAB, 3=Activity(push), 4=Account
  /// Stack: 0=Home, 1=Watchlist, 2=Account
  int _navToStackIndex(int navIndex) {
    switch (navIndex) {
      case 1:
        return 1;
      case 4:
        return 2;
      default:
        return 0;
    }
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (index == 2) {
      _showCreateSheet();
      return;
    }
    if (index == 3) {
      context.push('/mazadat/bids');
      return;
    }
    setState(() => _selectedNavIndex = index);
  }

  void _showCreateSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MazadatCreateSheet(
        onLiveAuction: () {
          Navigator.pop(ctx);
          context.push('/mazadat/create');
        },
        onFixedProduct: () {
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showSortFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SortFilterSheet(
        cubit: _cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _categoryCubit),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // ── Body Switcher ────────────────────────
            IndexedStack(
              index: _navToStackIndex(_selectedNavIndex),
              children: [
                // Tab 0: Home (marketplace)
                SafeArea(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
              // ── App Bar ────────────────────────────────
              SliverAppBar(
                backgroundColor: AppTheme.background,
                elevation: 0,
                pinned: true,
                centerTitle: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                ),
                title: Text(
                  'سوق المزادات',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                actions: [
                  // Wallet badge (from Stitch Screen 8)
                  Container(
                    margin: EdgeInsets.only(left: 16.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: AppTheme.mazadGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            color: AppTheme.mazadGreen, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          '٠ د.ع',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),

              // ── Featured Banner Hero ───────────────────
              BlocBuilder<AuctionsCubit, AuctionsState>(
                builder: (context, state) {
                  if (state.auctions.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  final banners = state.auctions.take(3).map((a) => Announcement(
                    id: a.id ?? '',
                    title: a.title,
                    subtitle: 'مزاد ينتهي قريباً',
                    imageUrl: a.images.isNotEmpty ? a.images.first : 'https://placehold.co/800x800/png',
                    colorHex: 0xFF2B3A67,
                    actionUrl: 'زايد الآن',
                  )).toList();
                  
                  return SliverToBoxAdapter(
                    child: AnnouncementsCarousel(
                      items: banners,
                      onTap: (item) {
                        final original = state.auctions.firstWhere((a) => a.id == item.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuctionLivePage(
                              auctionId: original.id ?? '',
                              title: original.title,
                              currentPrice: '${original.currentPrice ?? 0}',
                              currency: 'د.ع',
                              imageUrl: original.images.isNotEmpty
                                  ? original.images.first
                                  : 'https://placehold.co/800x800/png',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // ── Sponsored Content (Stitch Screen 2) ────
              SliverToBoxAdapter(
                child: _SponsoredSection(cubit: _cubit),
              ),

              // ── View Toggle + Filter (Stitch Screen 2) ─
              SliverToBoxAdapter(
                child: _ViewToggleAndFilter(
                  isGridView: _isGridView,
                  onViewChanged: (isGrid) {
                    setState(() => _isGridView = isGrid);
                  },
                  onSortFilterTap: _showSortFilterSheet,
                ),
              ),

              // ── Category Chips ─────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48.h,
                  child: BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      return state.map(
                        initial: (_) => const SizedBox.shrink(),
                        loading: (_) => const CategoryChipsSkeleton(),
                        error: (e) => Center(
                          child: Text(
                            e.message,
                            style:
                                GoogleFonts.cairo(color: AppTheme.textSecondary),
                          ),
                        ),
                        loaded: (loaded) {
                          final cats = loaded.categories;
                          final hasBack = loaded.parentIdStack.isNotEmpty;
                          return ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length + (hasBack ? 1 : 0) + 1,
                            separatorBuilder: (_, _) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              // "All" chip
                              if (index == 0 && !hasBack) {
                                return _CategoryChip(
                                  label: 'الكل',
                                  isSelected: true,
                                  onTap: () {},
                                );
                              }
                              if (hasBack && index == 0) {
                                return _CategoryChip(
                                  label: 'رجوع',
                                  isBack: true,
                                  onTap: () => context
                                      .read<CategoryCubit>()
                                      .navigateBack(),
                                );
                              }
                              final catIndex =
                                  hasBack ? index - 1 : index - 1;
                              if (catIndex < 0 || catIndex >= cats.length) {
                                return const SizedBox.shrink();
                              }
                              final cat = cats[catIndex];
                              return _CategoryChip(
                                label: cat.nameAr,
                                onTap: () => context
                                    .read<CategoryCubit>()
                                    .drillDown(cat.id),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // ── "Hot Auctions Now" Header ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppTheme.mazadGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'مزادات ساخنة الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'عرض الكل',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.mazadGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Auction Cards ──────────────────────────
              BlocBuilder<AuctionsCubit, AuctionsState>(
                builder: (context, state) {
                  if (state.isLoading && state.auctions.isEmpty) {
                    return const AuctionListSkeleton();
                  }
                  if (state.auctions.isEmpty) {
                    return SliverFillRemaining(child: _EmptyAuctions());
                  }
                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                    sliver: _isGridView
                        ? SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16.h,
                              crossAxisSpacing: 16.w,
                              childAspectRatio: 0.55,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _AuctionGridCard(auction: state.auctions[index]),
                              childCount: state.auctions.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: _AuctionCard(auction: state.auctions[index]),
                              ),
                              childCount: state.auctions.length,
                            ),
                          ),
                  );
                },
              ),
                ],
              ),
            ),
            // Tab 1: Watchlist
            const MazadatWatchlistPage(),
            // Tab 4: Account (mapped to index 2 in IndexedStack)
            const MazadatAccountPage(),
          ],
        ),
        // ── Mazadat Bottom Nav (Stitch Screen 8) ──
        _MazadatBottomNav(
          currentIndex: _selectedNavIndex,
          onTap: _onNavTap,
        ),
      ],
    ),
      ),
    );
  }
}


// ── Sponsored Content Section (Stitch Screen 2) ────────────────────────────
class _SponsoredSection extends StatelessWidget {
  final AuctionsCubit cubit;
  const _SponsoredSection({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(Icons.stars_rounded,
                  color: AppTheme.mazadGreen, size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                'محتوى ممول',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 100.h,
          child: BlocBuilder<AuctionsCubit, AuctionsState>(
            bloc: cubit,
            builder: (context, state) {
              final items = state.auctions.take(4).toList();
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (_, index) =>
                    _SponsoredCard(auction: items[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SponsoredCard extends StatelessWidget {
  final AuctionModel auction;
  const _SponsoredCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final hasImage = auction.images.isNotEmpty;
    return Container(
      width: 240.w,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 76.w,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              color: AppTheme.shimmerBase,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  CachedNetworkImage(
                    imageUrl: auction.images.first,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.shimmerBase),
                    errorWidget: (_, _, _) =>
                        Container(color: AppTheme.shimmerBase),
                  )
                else
                  Icon(Icons.gavel_rounded,
                      size: 24.sp, color: AppTheme.shimmerHighlight),
                // Time overlay
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: auction.endTime != null
                      ? _CountdownPill(endTime: auction.endTime!)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        auction.category ?? 'إلكترونيات',
                        style: GoogleFonts.cairo(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.mazadGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      auction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'يبدأ من',
                      style: GoogleFonts.cairo(
                        fontSize: 8.sp,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    Text(
                      IqdFormatter.format(
                        (auction.startPrice ?? auction.currentPrice ?? 0)
                            .toDouble(),
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.success,
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

// ── View Toggle + Filter (Stitch Screen 2) ──────────────────────────────────
class _ViewToggleAndFilter extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final VoidCallback onSortFilterTap;

  const _ViewToggleAndFilter({
    required this.isGridView,
    required this.onViewChanged,
    required this.onSortFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
      child: Row(
        children: [
          // View toggle
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onViewChanged(false),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: !isGridView ? AppTheme.surfaceAlt : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      boxShadow: !isGridView ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ] : null,
                    ),
                    child: Icon(Icons.view_agenda_rounded,
                        size: 16.sp, color: !isGridView ? AppTheme.textPrimary : AppTheme.textTertiary),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => onViewChanged(true),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: isGridView ? AppTheme.surfaceAlt : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      boxShadow: isGridView ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ] : null,
                    ),
                    child: Icon(Icons.grid_view_rounded,
                        size: 16.sp, color: isGridView ? AppTheme.textPrimary : AppTheme.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Sort & Filter button
          GestureDetector(
            onTap: onSortFilterTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ترتيب وتصفية',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.tune_rounded,
                      size: 16.sp, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chip ───────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isBack;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.isBack = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.textPrimary : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? AppTheme.textPrimary : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBack) ...[
              Icon(Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary, size: 14.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────────────────────────────
class _EmptyAuctions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                size: 40.sp,
                color: AppTheme.mazadGreen.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا توجد مزادات نشطة حالياً',
              style: GoogleFonts.cairo(
                color: AppTheme.textSecondary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'تابعنا لتكون أول من يعرف عن المزادات الجديدة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: AppTheme.textTertiary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auction Card (Stitch Screen 8 style) ────────────────────────────────────
class _AuctionCard extends StatelessWidget {
  final AuctionModel auction;

  const _AuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final hasImage = auction.images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuctionLivePage(
              auctionId: auction.id ?? '',
              title: auction.title,
              currentPrice: '${auction.currentPrice ?? 0}',
              currency: 'د.ع',
              imageUrl: hasImage
                  ? auction.images.first
                  : 'https://placehold.co/800x800/png',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.divider, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image Section (taller: 240h) ──
            SizedBox(
              height: 240.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: auction.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppTheme.shimmerBase),
                      errorWidget: (_, _, _) =>
                          Container(color: AppTheme.shimmerBase),
                    )
                  else
                    Container(
                      color: AppTheme.shimmerBase,
                      child: Icon(Icons.gavel_rounded,
                          size: 48.sp, color: AppTheme.shimmerHighlight),
                    ),
                  // Timer badge (top-right, dark pill with gold timer icon)
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: _CountdownPill(
                        endTime: auction.endTime ?? DateTime.now()),
                  ),
                  // Favorite button (top-left, Stitch Screen 2)
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Icon(
                              Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Info Section ──
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auction.title,
                              style: GoogleFonts.cairo(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (auction.condition != null) ...[
                              SizedBox(height: 4.h),
                              Text(
                                'الحالة: ${auction.condition}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'أعلى عطاء',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          Text(
                            IqdFormatter.format(
                              (auction.currentPrice ?? auction.startPrice ?? 0)
                                  .toDouble(),
                            ),
                            style: AppTheme.priceStyle(
                              fontSize: 20.sp,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Full-width bid button (Stitch pattern)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: AppTheme.mazadGreen,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mazadGreen.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'زايد الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.trending_up_rounded,
                            color: AppTheme.textPrimary, size: 20.sp),
                      ],
                    ),
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

// ── Countdown Pill ──────────────────────────────────────────────────────────
class _CountdownPill extends StatefulWidget {
  final DateTime endTime;
  const _CountdownPill({required this.endTime});

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      _timeLeft = widget.endTime.difference(DateTime.now());
      if (_timeLeft.isNegative) _timeLeft = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _timeLeft == Duration.zero;
    final h = _timeLeft.inHours.toString().padLeft(2, '0');
    final m = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded,
              color: AppTheme.accentYellow, size: 14.sp),
          SizedBox(width: 6.w),
          Text(
            isExpired ? 'انتهى' : '$h:$m:$s',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mazadat Bottom Nav (Stitch Screen 8 pattern) ────────────────────────────
class _MazadatBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MazadatBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(
                  color: AppTheme.divider.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MazadatNavItem(
                      icon: Icons.home_rounded,
                      filledIcon: Icons.home_rounded,
                      label: 'الرئيسية',
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _MazadatNavItem(
                      icon: Icons.visibility_outlined,
                      filledIcon: Icons.visibility_rounded,
                      label: 'المراقبة',
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    // ── Center FAB (Stitch: black circle + primary icon) ──
                    Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: GestureDetector(
                        onTap: () => onTap(2),
                        child: Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppTheme.mazadGreen,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ),
                    _MazadatNavItem(
                      icon: Icons.history_rounded,
                      filledIcon: Icons.history_rounded,
                      label: 'نشاطي',
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _MazadatNavItem(
                      icon: Icons.person_outline_rounded,
                      filledIcon: Icons.person_rounded,
                      label: 'حسابي',
                      isActive: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mazadat Nav Item ────────────────────────────────────────────────────────
class _MazadatNavItem extends StatelessWidget {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MazadatNavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.mazadGreen : AppTheme.inactive;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? filledIcon : icon, color: color, size: 24.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Action Bottom Sheet (Stitch Screen 8) ───────────────────────────
class _MazadatCreateSheet extends StatelessWidget {
  final VoidCallback onLiveAuction;
  final VoidCallback onFixedProduct;

  const _MazadatCreateSheet({
    required this.onLiveAuction,
    required this.onFixedProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 80.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 28.h),
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.inactive,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              Text(
                'ماذا تود أن تضيف؟',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              // Options grid
              Row(
                children: [
                  Expanded(
                    child: _CreateOption(
                      icon: Icons.bolt_rounded,
                      label: 'إضافة مزاد مباشر',
                      iconBgColor: AppTheme.mazadGreen.withValues(alpha: 0.12),
                      iconColor: AppTheme.mazadGreen,
                      onTap: onLiveAuction,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _CreateOption(
                      icon: Icons.inventory_2_rounded,
                      label: 'إضافة منتج ثابت',
                      iconBgColor: AppTheme.surface,
                      iconColor: AppTheme.textSecondary,
                      onTap: onFixedProduct,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              // Cancel
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'إلغاء',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create Option Card ──────────────────────────────────────────────────────
class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.label,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auction Grid Card ───────────────────────────────────────────────────────
class _AuctionGridCard extends StatelessWidget {
  final AuctionModel auction;

  const _AuctionGridCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final hasImage = auction.images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuctionLivePage(
              auctionId: auction.id ?? '',
              title: auction.title,
              currentPrice: '${auction.currentPrice ?? 0}',
              currency: 'د.ع',
              imageUrl: hasImage
                  ? auction.images.first
                  : 'https://placehold.co/800x800/png',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: auction.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppTheme.shimmerBase),
                      errorWidget: (_, _, _) =>
                          Container(color: AppTheme.shimmerBase),
                    )
                  else
                    Container(
                      color: AppTheme.shimmerBase,
                      child: Icon(Icons.gavel_rounded,
                          size: 32.sp, color: AppTheme.shimmerHighlight),
                    ),
                  // Timer badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: auction.endTime != null
                        ? _CountdownPill(endTime: auction.endTime!)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auction.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أعلى عطاء',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          IqdFormatter.format(
                            (auction.currentPrice ?? auction.startPrice ?? 0)
                                .toDouble(),
                          ),
                          style: AppTheme.priceStyle(
                            fontSize: 16.sp,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
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

// ── Sort & Filter Sheet ─────────────────────────────────────────────────────
class _SortFilterSheet extends StatefulWidget {
  final AuctionsCubit cubit;

  const _SortFilterSheet({required this.cubit});

  @override
  State<_SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<_SortFilterSheet> {
  late String _sortBy;
  late String _filterStatus;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.cubit.state.sortBy;
    _filterStatus = widget.cubit.state.filterStatus;
  }

  void _applyFilter() {
    widget.cubit.setSortBy(_sortBy);
    widget.cubit.setFilterStatus(_filterStatus);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 80.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 24.h),
              width: 48.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.inactive,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Text(
            'ترتيب وتصفية',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'حالة المزاد',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _FilterChip(
                label: 'الكل',
                isSelected: _filterStatus == 'all',
                onSelected: (val) => setState(() => _filterStatus = 'all'),
              ),
              _FilterChip(
                label: 'نشط',
                isSelected: _filterStatus == 'live',
                onSelected: (val) => setState(() => _filterStatus = 'live'),
              ),
              _FilterChip(
                label: 'قادم',
                isSelected: _filterStatus == 'upcoming',
                onSelected: (val) => setState(() => _filterStatus = 'upcoming'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'الترتيب',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ...[
            {'label': 'ينتهي قريباً', 'value': 'ending_soon'},
            {'label': 'السعر: من الأقل للأعلى', 'value': 'price_asc'},
            {'label': 'السعر: من الأعلى للأقل', 'value': 'price_desc'},
          ].map((item) => ListTile(
                title: Text(
                  item['label']!,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                leading: Icon(
                  _sortBy == item['value']! 
                      ? Icons.radio_button_checked_rounded 
                      : Icons.radio_button_unchecked_rounded,
                  color: _sortBy == item['value']! 
                      ? AppTheme.primary 
                      : AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                onTap: () => setState(() => _sortBy = item['value']!),
                contentPadding: EdgeInsets.zero,
              )),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Text(
                'تطبيق',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceAlt,
    );
  }
}
