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

// ── Mazadat design tokens ─────────────────────────────────────────────────
const _kBg         = Color(0xFF0A0A0F);
const _kSurface    = Color(0xFF12121A);
const _kBorder     = Color(0xFF1E1E2A);
const _kCyan       = Color(0xFF00F5FF);
const _kGold       = Color(0xFFFFD700);
const _kPrimary    = AppTheme.accentRed;   // 0xFFFF3B30 — close enough to FF3D5A

/// مزادات — Auctions marketplace hub.
///
/// Stitch "Mazadat Home Page Redesign" — dark neon theme.
/// bg=#0A0A0F, cyan=#00F5FF, primary=#FF3B30, gold=#FFD700.
class MazadatPage extends StatefulWidget {
  /// When true, hides the built-in bottom nav (shell provides it instead).
  final bool embeddedInShell;

  const MazadatPage({super.key, this.embeddedInShell = false});

  @override
  State<MazadatPage> createState() => _MazadatPageState();
}

class _MazadatPageState extends State<MazadatPage> {
  late final AuctionsCubit _cubit;
  late final CategoryCubit _categoryCubit;
  int _selectedNavIndex = 0;
  bool _isGridView = true;

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
        backgroundColor: _kBg,
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
                      // ── App Bar ──────────────────────────────────────────
                      SliverAppBar(
                        backgroundColor: _kBg,
                        elevation: 0,
                        pinned: true,
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        // Right: notifications
                        leading: IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          onPressed: () {},
                        ),
                        title: Text(
                          'مزادات',
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Left: wallet chip
                        actions: [
                          _WalletChip(),
                          SizedBox(width: 8.w),
                        ],
                      ),

                      // ── Search Bar ───────────────────────────────────────
                      SliverToBoxAdapter(
                        child: _SearchBar(),
                      ),

                      // ── Featured Banner ──────────────────────────────────
                      BlocBuilder<AuctionsCubit, AuctionsState>(
                        builder: (context, state) {
                          if (state.auctions.isEmpty) {
                            return const SliverToBoxAdapter(
                                child: SizedBox.shrink());
                          }
                          return SliverToBoxAdapter(
                            child: _FeaturedBanner(
                              auctions: state.auctions.take(3).toList(),
                              onTap: (auction) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AuctionLivePage(
                                      auctionId: auction.id ?? '',
                                      title: auction.title,
                                      currentPrice:
                                          '${auction.currentPrice ?? 0}',
                                      currency: 'د.ع',
                                      imageUrl: auction.images.isNotEmpty
                                          ? auction.images.first
                                          : 'https://placehold.co/800x800/png',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // ── Category Chips ───────────────────────────────────
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
                                    style: GoogleFonts.cairo(
                                        color: Colors.white54),
                                  ),
                                ),
                                loaded: (loaded) {
                                  final cats = loaded.categories;
                                  final hasBack =
                                      loaded.parentIdStack.isNotEmpty;
                                  return ListView.separated(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cats.length +
                                        (hasBack ? 1 : 0) +
                                        1,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(width: 8.w),
                                    itemBuilder: (context, index) {
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
                                      if (catIndex < 0 ||
                                          catIndex >= cats.length) {
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

                      // ── Filter / View Row ────────────────────────────────
                      SliverToBoxAdapter(
                        child: _FilterViewRow(
                          isGridView: _isGridView,
                          onViewChanged: (isGrid) =>
                              setState(() => _isGridView = isGrid),
                          onSortFilterTap: _showSortFilterSheet,
                        ),
                      ),

                      // ── "مزادات ساخنة" Header ────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
                          child: Row(
                            children: [
                              Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                  color: _kPrimary,
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
                                    color: Colors.white,
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
                                    color: _kCyan,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Auction Cards ────────────────────────────────────
                      BlocBuilder<AuctionsCubit, AuctionsState>(
                        builder: (context, state) {
                          if (state.isLoading && state.auctions.isEmpty) {
                            return const AuctionListSkeleton();
                          }
                          if (state.auctions.isEmpty) {
                            return SliverFillRemaining(
                                child: _EmptyAuctions());
                          }
                          return SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                                16.w, 0, 16.w, 100.h),
                            sliver: _isGridView
                                ? SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16.h,
                                      crossAxisSpacing: 16.w,
                                      childAspectRatio: 0.55,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _AuctionGridCard(
                                          auction: state.auctions[index]),
                                      childCount: state.auctions.length,
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => Padding(
                                        padding:
                                            EdgeInsets.only(bottom: 16.h),
                                        child: _AuctionCard(
                                            auction:
                                                state.auctions[index]),
                                      ),
                                      childCount: state.auctions.length,
                                    ),
                                  ),
                          );
                        },
                      ),

                      // ── "مزادات منتهية قريباً" Section ──────────────────
                      SliverToBoxAdapter(
                        child: _EndingSoonSection(cubit: _cubit),
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
            // Bottom nav hidden when hosted inside MazadatShellPage
            if (!widget.embeddedInShell)
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

// ── Wallet Chip ──────────────────────────────────────────────────────────────
class _WalletChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _kCyan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _kCyan.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_rounded,
              color: _kCyan, size: 16.sp),
          SizedBox(width: 5.w),
          Text(
            '٠ د.ع',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: _kCyan,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: _kCyan, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              'ابحث عن مزاد...',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured Banner ──────────────────────────────────────────────────────────
class _FeaturedBanner extends StatefulWidget {
  final List<AuctionModel> auctions;
  final ValueChanged<AuctionModel> onTap;

  const _FeaturedBanner({
    required this.auctions,
    required this.onTap,
  });

  @override
  State<_FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<_FeaturedBanner> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.auctions.isEmpty) return const SizedBox.shrink();
    final auction = widget.auctions[_currentPage];
    final hasImage = auction.images.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: GestureDetector(
        onTap: () => widget.onTap(auction),
        child: Container(
          height: 180.h,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _kBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (hasImage)
                CachedNetworkImage(
                  imageUrl: auction.images.first,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: _kSurface),
                  errorWidget: (_, _, _) => Container(color: _kSurface),
                )
              else
                Container(
                  color: _kSurface,
                  child: Icon(Icons.gavel_rounded,
                      size: 48.sp, color: Colors.white12),
                ),

              // Dark gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // "مميز" badge top-right (RTL leading)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'مميز',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Bottom content
              Positioned(
                bottom: 14.h,
                left: 14.w,
                right: 14.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'أعلى مزايدة حالية',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            IqdFormatter.format(
                              (auction.currentPrice ??
                                      auction.startPrice ??
                                      0)
                                  .toDouble(),
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: _kCyan,
                              height: 1.1,
                            ),
                          ),
                        ),
                        if (auction.endTime != null)
                          _CountdownPill(endTime: auction.endTime!),
                      ],
                    ),
                  ],
                ),
              ),

              // Page dots (if multiple)
              if (widget.auctions.length > 1)
                Positioned(
                  top: 12.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.auctions.length,
                      (i) => GestureDetector(
                        onTap: () => setState(() => _currentPage = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: _currentPage == i ? 16.w : 6.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? _kCyan
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
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

// ── Filter / View Row ────────────────────────────────────────────────────────
class _FilterViewRow extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final VoidCallback onSortFilterTap;

  const _FilterViewRow({
    required this.isGridView,
    required this.onViewChanged,
    required this.onSortFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Row(
        children: [
          // Sort dropdown-style button (right side in RTL)
          GestureDetector(
            onTap: onSortFilterTap,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded, color: Colors.white54, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'مرتب بـ: الأحدث',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white38, size: 16.sp),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Grid / List toggle icons
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleIcon(
                  icon: Icons.grid_view_rounded,
                  isActive: isGridView,
                  onTap: () => onViewChanged(true),
                ),
                SizedBox(width: 2.w),
                _ToggleIcon(
                  icon: Icons.view_agenda_rounded,
                  isActive: !isGridView,
                  onTap: () => onViewChanged(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.isActive,
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
        duration: const Duration(milliseconds: 180),
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: isActive ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: isActive ? Colors.white : Colors.white38,
        ),
      ),
    );
  }
}

// ── Category Chip ────────────────────────────────────────────────────────────
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
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : _kSurface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? _kPrimary : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBack) ...[
              Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 14.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────────
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
                color: _kPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                size: 40.sp,
                color: _kPrimary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'لا توجد مزادات نشطة حالياً',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'تابعنا لتكون أول من يعرف عن المزادات الجديدة',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white38,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── "مزادات منتهية قريباً" Section ──────────────────────────────────────────
class _EndingSoonSection extends StatelessWidget {
  final AuctionsCubit cubit;
  const _EndingSoonSection({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuctionsCubit, AuctionsState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.auctions.isEmpty) return const SizedBox.shrink();
        final items = state.auctions
            .where((a) =>
                a.endTime != null &&
                a.endTime!.difference(DateTime.now()).inHours < 24)
            .take(6)
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: _kPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'مزادات منتهية قريباً',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (_, index) =>
                    _EndingSoonCard(auction: items[index]),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}

class _EndingSoonCard extends StatelessWidget {
  final AuctionModel auction;
  const _EndingSoonCard({required this.auction});

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
        width: 140.w,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: auction.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: _kBorder),
                      errorWidget: (_, _, _) => Container(color: _kBorder),
                    )
                  else
                    Container(
                      color: _kBorder,
                      child: Icon(Icons.gavel_rounded,
                          size: 28.sp, color: Colors.white24),
                    ),
                  if (auction.endTime != null)
                    Positioned(
                      bottom: 6.h,
                      left: 6.w,
                      right: 6.w,
                      child: _CountdownPill(endTime: auction.endTime!),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auction.title,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      IqdFormatter.format(
                        (auction.currentPrice ?? auction.startPrice ?? 0)
                            .toDouble(),
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: _kCyan,
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

// ── Auction Card (list view) ─────────────────────────────────────────────────
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
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image Section ────────────────────────
            SizedBox(
              height: 200.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: auction.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: _kBorder),
                      errorWidget: (_, _, _) => Container(color: _kBorder),
                    )
                  else
                    Container(
                      color: _kBorder,
                      child: Icon(Icons.gavel_rounded,
                          size: 48.sp, color: Colors.white12),
                    ),
                  // Timer badge
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: _CountdownPill(
                        endTime: auction.endTime ?? DateTime.now()),
                  ),
                  // Status badge
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: _StatusBadge(status: auction.status),
                  ),
                  // Favourite button
                  Positioned(
                    bottom: 12.h,
                    left: 12.w,
                    child: GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
            // ── Info Section ─────────────────────────
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                        color: Colors.white38,
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أعلى عطاء',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              color: Colors.white38,
                            ),
                          ),
                          Text(
                            IqdFormatter.format(
                              (auction.currentPrice ??
                                      auction.startPrice ??
                                      0)
                                  .toDouble(),
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: _kCyan,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Bid button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AuctionLivePage(
                                auctionId: auction.id ?? '',
                                title: auction.title,
                                currentPrice:
                                    '${auction.currentPrice ?? 0}',
                                currency: 'د.ع',
                                imageUrl: hasImage
                                    ? auction.images.first
                                    : 'https://placehold.co/800x800/png',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            borderRadius: BorderRadius.circular(999.r),
                            boxShadow: [
                              BoxShadow(
                                color: _kPrimary.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'زايد الآن',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
      ),
    );
  }
}

// ── Auction Grid Card ────────────────────────────────────────────────────────
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
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasImage)
                    CachedNetworkImage(
                      imageUrl: auction.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: _kBorder),
                      errorWidget: (_, _, _) => Container(color: _kBorder),
                    )
                  else
                    Container(
                      color: _kBorder,
                      child: Icon(Icons.gavel_rounded,
                          size: 32.sp, color: Colors.white12),
                    ),
                  // Status badge
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: _StatusBadge(status: auction.status),
                  ),
                  // Timer
                  if (auction.endTime != null)
                    Positioned(
                      bottom: 6.h,
                      left: 4.w,
                      right: 4.w,
                      child: _CountdownPill(endTime: auction.endTime!),
                    ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auction.title,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            fontSize: 9.sp,
                            color: Colors.white38,
                          ),
                        ),
                        Text(
                          IqdFormatter.format(
                            (auction.currentPrice ??
                                    auction.startPrice ??
                                    0)
                                .toDouble(),
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: _kCyan,
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

// ── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isLive = status == 'active' || status == 'live';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isLive
            ? _kPrimary.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isLive ? _kPrimary : Colors.white24,
        ),
      ),
      child: Text(
        isLive ? 'مباشر' : 'قادم',
        style: GoogleFonts.cairo(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Countdown Pill ───────────────────────────────────────────────────────────
class _CountdownPill extends StatefulWidget {
  final DateTime endTime;
  const _CountdownPill({required this.endTime});

  @override
  State<_CountdownPill> createState() => _CountdownPillState();
}

class _CountdownPillState extends State<_CountdownPill>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    final remaining = widget.endTime.difference(DateTime.now());
    setState(() {
      _timeLeft = remaining.isNegative ? Duration.zero : remaining;
    });
    if (_timeLeft.inSeconds <= 10 && _timeLeft.inSeconds > 0) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _timeLeft == Duration.zero;
    final isPulsing = _timeLeft.inSeconds <= 10 && !isExpired;
    final h = _timeLeft.inHours.toString().padLeft(2, '0');
    final m = _timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0');

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, _) {
        final pulseAlpha = isPulsing
            ? 0.7 + (_pulseController.value * 0.3)
            : 0.85;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: pulseAlpha),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isPulsing
                  ? _kPrimary.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_rounded,
                color: isPulsing ? _kPrimary : Colors.white70,
                size: 12.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                isExpired ? 'انتهى' : '$h:$m:$s',
                style: GoogleFonts.cairo(
                  color: isPulsing ? _kPrimary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Mazadat Bottom Nav ───────────────────────────────────────────────────────
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
              color: _kSurface.withValues(alpha: 0.95),
              border: const Border(
                top: BorderSide(color: _kBorder),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MazadatNavItem(
                      icon: Icons.home_outlined,
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
                    // Center FAB
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: GestureDetector(
                        onTap: () => onTap(2),
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: _kPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _kPrimary.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28.sp,
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

// ── Nav Item ─────────────────────────────────────────────────────────────────
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
    final color = isActive ? _kCyan : Colors.white38;
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

// ── Create Action Bottom Sheet ───────────────────────────────────────────────
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
        color: _kSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32.r),
        ),
        border: const Border(
          top: BorderSide(color: _kBorder),
        ),
      ),
      clipBehavior: Clip.antiAlias,
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              'ماذا تود أن تضيف؟',
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _CreateOption(
                    icon: Icons.bolt_rounded,
                    label: 'إضافة مزاد مباشر',
                    iconBgColor: _kPrimary.withValues(alpha: 0.15),
                    iconColor: _kPrimary,
                    onTap: onLiveAuction,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _CreateOption(
                    icon: Icons.inventory_2_rounded,
                    label: 'إضافة منتج ثابت',
                    iconBgColor: _kBorder,
                    iconColor: Colors.white54,
                    onTap: onFixedProduct,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                alignment: Alignment.center,
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Create Option Card ───────────────────────────────────────────────────────
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
          color: _kBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: _kBorder),
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort & Filter Sheet ──────────────────────────────────────────────────────
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
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        border: const Border(top: BorderSide(color: _kBorder)),
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Text(
            'ترتيب وتصفية',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'حالة المزاد',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _FilterChip(
                label: 'الكل',
                isSelected: _filterStatus == 'all',
                onSelected: (_) => setState(() => _filterStatus = 'all'),
              ),
              _FilterChip(
                label: 'نشط',
                isSelected: _filterStatus == 'live',
                onSelected: (_) => setState(() => _filterStatus = 'live'),
              ),
              _FilterChip(
                label: 'قادم',
                isSelected: _filterStatus == 'upcoming',
                onSelected: (_) =>
                    setState(() => _filterStatus = 'upcoming'),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'الترتيب',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
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
                    color: Colors.white,
                  ),
                ),
                leading: Icon(
                  _sortBy == item['value']!
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _sortBy == item['value']!
                      ? _kCyan
                      : Colors.white24,
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
                backgroundColor: _kPrimary,
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
          color: isSelected ? Colors.white : Colors.white60,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: _kPrimary,
      backgroundColor: _kBorder,
      side: BorderSide(
        color: isSelected ? _kPrimary : Colors.white24,
      ),
    );
  }
}
