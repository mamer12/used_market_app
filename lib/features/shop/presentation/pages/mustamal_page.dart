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
import '../../../../core/widgets/center_fab_bottom_nav.dart';
import '../../../../core/widgets/promoted_carousel.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

// ── Mustamal colour tokens ─────────────────────────────────────────────────
const _orange = AppTheme.mustamalOrange;
const _bg = Color(0xFFFFF8F5);

// ── Static category chip data ──────────────────────────────────────────────
const _categoryChips = [
  _ChipData(label: 'الكل', isAll: true),
  _ChipData(label: 'هواتف'),
  _ChipData(label: 'سيارات'),
  _ChipData(label: 'أثاث'),
  _ChipData(label: 'إلكترونيات'),
  _ChipData(label: 'ملابس'),
];

// ── Trending search terms ──────────────────────────────────────────────────
const _trendingTerms = ['ايفون ١٥', 'بلايستيشن ٥', 'لابتوب', 'دراجة'];

// ── Mock listing data ──────────────────────────────────────────────────────
const _mockListings = [
  _MockListing(
    title: 'آيفون ١٥ برو ماكس - ٢٥٦ جيجا',
    price: 1250000,
    condition: 'ممتاز',
    location: 'المنصور',
    timeAgo: 'منذ ٣ ساعات',
  ),
  _MockListing(
    title: 'بلايستيشن ٥ مع ٣ العاب',
    price: 750000,
    condition: 'جيد جداً',
    location: 'الكرادة',
    timeAgo: 'منذ ٥ ساعات',
  ),
  _MockListing(
    title: 'لابتوب ديل XPS 15',
    price: 950000,
    condition: 'مقبول',
    location: 'الجادرية',
    timeAgo: 'منذ ١ يوم',
  ),
  _MockListing(
    title: 'تلفزيون سامسونج ٦٥ بوصة',
    price: 580000,
    condition: 'ممتاز',
    location: 'الزيونة',
    timeAgo: 'منذ ٢ ساعات',
  ),
  _MockListing(
    title: 'دراجة هوائية اطفال',
    price: 85000,
    condition: 'جيد جداً',
    location: 'الأعظمية',
    timeAgo: 'منذ ٧ ساعات',
  ),
  _MockListing(
    title: 'كاميرا كانون R50 مع عدسة',
    price: 1100000,
    condition: 'ممتاز',
    location: 'المسبح',
    timeAgo: 'منذ ٤ ساعات',
  ),
];

// ── Page ───────────────────────────────────────────────────────────────────

class MustamalPage extends StatefulWidget {
  const MustamalPage({super.key});

  @override
  State<MustamalPage> createState() => _MustamalPageState();
}

class _MustamalPageState extends State<MustamalPage> {
  late final HomeCubit _cubit;
  final String _location = 'بغداد';
  int _selectedCategoryIndex = 0;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: _bg,
        bottomNavigationBar: CenterFabBottomNav(
          items: const [
            NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
            NavItem(icon: Icons.category_rounded, label: 'الأقسام'),
            NavItem(icon: Icons.campaign_rounded, label: 'إعلاناتي'),
            NavItem(icon: Icons.person_rounded, label: 'حسابي'),
          ],
          currentIndex: 0,
          onTap: (index) {
            if (index == 2) context.push('/mustamal/my-ads');
          },
          fabIcon: Icons.camera_alt_rounded,
          fabColor: AppTheme.mustamalOrange,
          fabLabel: 'أضف إعلان',
          onFabTap: () => context.push('/mustamal/create'),
          darkMode: false,
        ),
        body: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── AppBar ──────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: _bg,
                elevation: 0,
                pinned: true,
                scrolledUnderElevation: 2,
                surfaceTintColor: _bg,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                automaticallyImplyLeading: false,
                title: Text(
                  l10n.homeSooqUsed,
                  style: GoogleFonts.tajawal(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: _orange, size: 24.sp),
                    onPressed: () => HapticFeedback.selectionClick(),
                    tooltip: 'فلتر',
                  ),
                  IconButton(
                    icon: Icon(Icons.search_rounded, color: _orange, size: 24.sp),
                    onPressed: () => HapticFeedback.selectionClick(),
                    tooltip: 'بحث',
                  ),
                  SizedBox(width: 4.w),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(1.h),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: _orange.withValues(alpha: 0.10),
                  ),
                ),
              ),

              // ── Trending Searches Row ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // label + pills in one horizontal scroll
                      SizedBox(
                        height: 38.h,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Label
                            Center(
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 10.w),
                                child: Text(
                                  'أكثر بحثاً:',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            // Pills
                            ..._trendingTerms.map((term) => _TrendingPill(term: term)),
                            SizedBox(width: 16.w),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Featured Listing Hero Card ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: _FeaturedHeroCard(
                    onContactTap: () => HapticFeedback.mediumImpact(),
                  ),
                ),
              ),

              // ── Post Ad Banner ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: _PostAdBanner(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/mustamal/create');
                    },
                  ),
                ),
              ),

              // ── Promoted Carousel ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: const PromotedCarousel(
                    primaryColor: AppTheme.mustamalOrange,
                    items: [
                      PromotedItem(
                        badge: 'مميز',
                        title: 'بيع وشري بكل سهولة',
                        subtitle: 'آلاف الإعلانات في بغداد',
                      ),
                      PromotedItem(
                        badge: 'جديد',
                        title: 'هواتف وأجهزة مستعملة',
                        subtitle: 'أسعار مناسبة وضمان المشتري',
                      ),
                      PromotedItem(
                        badge: 'الأكثر بحثاً',
                        title: 'سيارات وعقارات',
                        subtitle: 'تصفّح الآلاف من الإعلانات',
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter Row: location + grid/list toggle ──────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: Row(
                    children: [
                      // Location chip
                      GestureDetector(
                        onTap: () => HapticFeedback.selectionClick(),
                        child: Container(
                          height: 36.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(
                                color: _orange.withValues(alpha: 0.20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded,
                                  color: _orange, size: 15.sp),
                              SizedBox(width: 4.w),
                              Text(
                                _location,
                                style: GoogleFonts.tajawal(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _orange, size: 16.sp),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Grid/List toggle
                      _ViewToggleButton(
                        isGrid: _isGridView,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _isGridView = !_isGridView);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ── Category Chips Row ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 12.h, 0, 12.h),
                  child: SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categoryChips.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final chip = _categoryChips[index];
                        final selected = _selectedCategoryIndex == index;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategoryIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 38.h,
                            padding:
                                EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: selected ? _orange : Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull),
                              border: Border.all(
                                color: selected
                                    ? _orange
                                    : _orange.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                chip.label,
                                style: GoogleFonts.tajawal(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ── Listings Grid / List ─────────────────────────────────
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.isLoading && state.portal.mustamal.isEmpty) {
                    return _isGridView
                        ? SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            sliver: SliverGrid.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: 0.72,
                              children: List.generate(
                                4,
                                (_) => SkeletonBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  borderRadius: 14.r,
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, _) => Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16.w, 0, 16.w, 12.h),
                                child: SkeletonBox(
                                  width: double.infinity,
                                  height: 110.h,
                                  borderRadius: 14.r,
                                ),
                              ),
                              childCount: 3,
                            ),
                          );
                  }

                  // Use mock data as fallback when portal is empty
                  final apiItems = state.portal.mustamal;
                  final showMock = apiItems.isEmpty;

                  if (_isGridView) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                      sliver: SliverGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.72,
                        children: showMock
                            ? _mockListings
                                .map((m) => _ListingGridCard(
                                      title: m.title,
                                      price: m.price,
                                      condition: m.condition,
                                      location: m.location,
                                      timeAgo: m.timeAgo,
                                      imageUrl: null,
                                      onTap: () =>
                                          HapticFeedback.selectionClick(),
                                      onFavoriteTap: () =>
                                          HapticFeedback.selectionClick(),
                                    ))
                                .toList()
                            : List.generate(apiItems.length, (i) {
                                final item = apiItems[i];
                                final mock =
                                    _mockListings[i % _mockListings.length];
                                return _ListingGridCard(
                                  title: (item.title as String?) ?? '',
                                  price: (item.price as num?) ?? 0,
                                  condition: mock.condition,
                                  location: mock.location,
                                  timeAgo: mock.timeAgo,
                                  imageUrl: ((item.images as List<String>?)
                                          ?.isNotEmpty ??
                                      false)
                                      ? (item.images as List<String>?)!.first
                                      : null,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    context.push(
                                        '/mustamal/${item.id}',
                                        extra: item);
                                  },
                                  onFavoriteTap: () =>
                                      HapticFeedback.selectionClick(),
                                );
                              }),
                      ),
                    );
                  } else {
                    // List view
                    final count =
                        showMock ? _mockListings.length : apiItems.length;
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                      sliver: SliverList.separated(
                        itemCount: count,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: 10.h),
                        itemBuilder: (context, i) {
                          if (showMock) {
                            final m = _mockListings[i];
                            return _ListingListCard(
                              title: m.title,
                              price: m.price,
                              condition: m.condition,
                              location: m.location,
                              timeAgo: m.timeAgo,
                              imageUrl: null,
                              onTap: () =>
                                  HapticFeedback.selectionClick(),
                              onFavoriteTap: () =>
                                  HapticFeedback.selectionClick(),
                            );
                          }
                          final item = apiItems[i];
                          final mock =
                              _mockListings[i % _mockListings.length];
                          return _ListingListCard(
                            title: (item.title as String?) ?? '',
                            price: (item.price as num?) ?? 0,
                            condition: mock.condition,
                            location: mock.location,
                            timeAgo: mock.timeAgo,
                            imageUrl: ((item.images as List<String>?)
                                    ?.isNotEmpty ??
                                false)
                                ? (item.images as List<String>?)!.first
                                : null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/mustamal/${item.id}',
                                  extra: item);
                            },
                            onFavoriteTap: () =>
                                HapticFeedback.selectionClick(),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Trending Pill ──────────────────────────────────────────────────────────

class _TrendingPill extends StatelessWidget {
  final String term;
  const _TrendingPill({required this.term});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        margin: EdgeInsetsDirectional.only(end: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: _orange.withValues(alpha: 0.40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, color: _orange, size: 13.sp),
            SizedBox(width: 4.w),
            Text(
              term,
              style: GoogleFonts.tajawal(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured Hero Card ─────────────────────────────────────────────────────

class _FeaturedHeroCard extends StatelessWidget {
  final VoidCallback onContactTap;
  const _FeaturedHeroCard({required this.onContactTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder image background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _orange.withValues(alpha: 0.15),
                  _orange.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.smartphone_rounded,
                color: _orange.withValues(alpha: 0.25), size: 80.sp),
          ),
          // Gradient overlay bottom
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
          ),
          // مميز badge (top start)
          PositionedDirectional(
            top: 12.h,
            start: 12.w,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _orange,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'مميز',
                style: GoogleFonts.tajawal(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Condition badge (top end)
          PositionedDirectional(
            top: 12.h,
            end: 12.w,
            child: const _ConditionBadge(condition: 'جيد جداً'),
          ),
          // Bottom info row
          PositionedDirectional(
            bottom: 12.h,
            start: 12.w,
            end: 12.w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'آيفون ١٥ برو - ٢٥٦ جيجا - بكج كامل',
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.white70, size: 13.sp),
                          SizedBox(width: 2.w),
                          Text(
                            'بغداد، الكرادة',
                            style: GoogleFonts.tajawal(
                              fontSize: 12.sp,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '٤٥,٠٠٠,٠٠٠ د.ع',
                        style: GoogleFonts.tajawal(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFB347),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                // WhatsApp contact button
                GestureDetector(
                  onTap: onContactTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_rounded,
                            color: Colors.white, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'تواصل',
                          style: GoogleFonts.tajawal(
                            fontSize: 12.sp,
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
        ],
      ),
    );
  }
}

// ── Post Ad Banner ─────────────────────────────────────────────────────────

class _PostAdBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PostAdBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _orange,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _orange.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'أضف إعلانك في ثواني مجاناً',
              style: GoogleFonts.tajawal(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                'أضف إعلان',
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: _orange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── View Toggle Button ─────────────────────────────────────────────────────

class _ViewToggleButton extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onTap;
  const _ViewToggleButton({required this.isGrid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: _orange.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          color: _orange,
          size: 20.sp,
        ),
      ),
    );
  }
}

// ── Condition Badge ────────────────────────────────────────────────────────

class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  Color get _badgeColor {
    switch (condition) {
      case 'ممتاز':
        return const Color(0xFF059669); // green
      case 'جيد جداً':
        return const Color(0xFF2563EB); // blue
      case 'مقبول':
        return _orange; // orange
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        'مستعمل - $condition',
        style: GoogleFonts.tajawal(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Listing Grid Card ──────────────────────────────────────────────────────

class _ListingGridCard extends StatelessWidget {
  final String title;
  final num price;
  final String condition;
  final String location;
  final String timeAgo;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _ListingGridCard({
    required this.title,
    required this.price,
    required this.condition,
    required this.location,
    required this.timeAgo,
    required this.imageUrl,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _orange.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              const _ImagePlaceholder(),
                        )
                      : const _ImagePlaceholder(),
                  // Condition badge
                  PositionedDirectional(
                    top: 8.h,
                    start: 8.w,
                    child: _ConditionBadge(condition: condition),
                  ),
                  // Favorite button
                  PositionedDirectional(
                    top: 6.h,
                    end: 6.w,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.90),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: AppTheme.textSecondary,
                          size: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info area
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(9.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      IqdFormatter.format(price),
                      style: GoogleFonts.tajawal(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: _orange,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppTheme.textSecondary, size: 11.sp),
                        SizedBox(width: 2.w),
                        Text(
                          location,
                          style: GoogleFonts.tajawal(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          timeAgo,
                          style: GoogleFonts.tajawal(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondary,
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

// ── Listing List Card ──────────────────────────────────────────────────────

class _ListingListCard extends StatelessWidget {
  final String title;
  final num price;
  final String condition;
  final String location;
  final String timeAgo;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _ListingListCard({
    required this.title,
    required this.price,
    required this.condition,
    required this.location,
    required this.timeAgo,
    required this.imageUrl,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _orange.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image
            SizedBox(
              width: 100.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              const _ImagePlaceholder(),
                        )
                      : const _ImagePlaceholder(),
                  PositionedDirectional(
                    bottom: 6.h,
                    start: 6.w,
                    child: _ConditionBadge(condition: condition),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.tajawal(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavoriteTap,
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: AppTheme.textSecondary,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      IqdFormatter.format(price),
                      style: GoogleFonts.tajawal(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: _orange,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppTheme.textSecondary, size: 12.sp),
                        SizedBox(width: 2.w),
                        Text(
                          location,
                          style: GoogleFonts.tajawal(
                            fontSize: 11.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeAgo,
                          style: GoogleFonts.tajawal(
                            fontSize: 11.sp,
                            color: AppTheme.inactive,
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

// ── Image Placeholder ──────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _orange.withValues(alpha: 0.07),
      child: Icon(
        Icons.image_rounded,
        color: _orange.withValues(alpha: 0.25),
        size: 28.sp,
      ),
    );
  }
}

// ── Data Models ────────────────────────────────────────────────────────────

class _ChipData {
  final String label;
  final bool isAll;
  const _ChipData({required this.label, this.isAll = false});
}

class _MockListing {
  final String title;
  final num price;
  final String condition;
  final String location;
  final String timeAgo;
  const _MockListing({
    required this.title,
    required this.price,
    required this.condition,
    required this.location,
    required this.timeAgo,
  });
}
