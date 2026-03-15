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
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/presentation/bloc/home_cubit.dart';

// ── Mustamal colour tokens ─────────────────────────────────────────────────
const _orange = AppTheme.mustamalOrange;
const _orangeSurface = Color(0xFFFFF8F0);

// ── Static category data ───────────────────────────────────────────────────
const _quickCategories = [
  _CategoryItem(icon: Icons.smartphone_rounded, label: 'هواتف', color: Color(0xFFFF6B35)),
  _CategoryItem(icon: Icons.directions_car_rounded, label: 'سيارات', color: Color(0xFF2196F3)),
  _CategoryItem(icon: Icons.real_estate_agent_rounded, label: 'عقارات', color: Color(0xFF4CAF50)),
  _CategoryItem(icon: Icons.chair_rounded, label: 'أثاث', color: Color(0xFFFF9800)),
  _CategoryItem(icon: Icons.checkroom_rounded, label: 'أزياء', color: Color(0xFFE91E63)),
  _CategoryItem(icon: Icons.storefront_rounded, label: 'أعمال', color: Color(0xFF9C27B0)),
  _CategoryItem(icon: Icons.sports_soccer_rounded, label: 'رياضة', color: Color(0xFF009688)),
  _CategoryItem(icon: Icons.menu_book_rounded, label: 'كتب', color: Color(0xFF3F51B5)),
];

const _allCategories = [
  _AllCategoryItem(
    icon: Icons.smartphone_rounded,
    label: 'هواتف وأجهزة',
    count: '٤,٥٦٧ إعلان',
    color: Color(0xFFFF6B35),
  ),
  _AllCategoryItem(
    icon: Icons.directions_car_rounded,
    label: 'سيارات ومركبات',
    count: '١,٢٣٠ إعلان',
    color: Color(0xFF2196F3),
  ),
  _AllCategoryItem(
    icon: Icons.real_estate_agent_rounded,
    label: 'عقارات وأراضي',
    count: '٨٩٠ إعلان',
    color: Color(0xFF4CAF50),
  ),
  _AllCategoryItem(
    icon: Icons.chair_rounded,
    label: 'أثاث ومفروشات',
    count: '٢,١٤٠ إعلان',
    color: Color(0xFFFF9800),
  ),
  _AllCategoryItem(
    icon: Icons.checkroom_rounded,
    label: 'أزياء وملابس',
    count: '٣,٨٠٠ إعلان',
    color: Color(0xFFE91E63),
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
  final String _location = 'بغداد — الكرادة';

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
        backgroundColor: _orangeSurface,
        body: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── AppBar ─────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: _orangeSurface,
                elevation: 0,
                pinned: true,
                scrolledUnderElevation: 2,
                surfaceTintColor: _orangeSurface,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                leading: IconButton(
                  icon: Icon(Icons.tune_rounded, color: _orange, size: 26.sp),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    // TODO: open filter sheet
                  },
                ),
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
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: 12.w),
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push('/mustamal/create');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        shape: const StadiumBorder(),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.mustamalSellButton,
                        style: GoogleFonts.tajawal(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
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

              // ── Search Bar ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: _orange.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 14.w),
                        Icon(Icons.search_rounded, color: _orange, size: 22.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.tajawal(fontSize: 14.sp),
                            decoration: InputDecoration(
                              hintText: l10n.mustamalSearchHint,
                              hintStyle: GoogleFonts.tajawal(
                                color: AppTheme.inactive,
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Location Row ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: Row(
                    children: [
                      // Current location chip
                      _LocationChip(
                        label: '📍 $_location',
                        trailing: Text(
                          l10n.mustamalLocationChange,
                          style: GoogleFonts.tajawal(
                            fontSize: 11.sp,
                            color: _orange.withValues(alpha: 0.7),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {},
                      ),
                      SizedBox(width: 10.w),
                      // Near me chip
                      _LocationChip(
                        icon: Icons.my_location_rounded,
                        label: l10n.mustamalNearMe,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Category Grid ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 10.w,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _quickCategories.length,
                    itemBuilder: (_, i) => _QuickCategoryTile(cat: _quickCategories[i]),
                  ),
                ),
              ),

              // ── Nearby Listings ───────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
                      child: Row(
                        children: [
                          Text(
                            '${l10n.mustamalNearbyTitle} 📍',
                            style: GoogleFonts.tajawal(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              l10n.homeSeeAll,
                              style: GoogleFonts.tajawal(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        if (state.isLoading && state.portal.mustamal.isEmpty) {
                          return SizedBox(
                            height: 200.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: 3,
                              separatorBuilder: (_, __) => SizedBox(width: 14.w),
                              itemBuilder: (_, __) => SkeletonBox(
                                width: 160.w,
                                height: 200.h,
                                borderRadius: 14.r,
                              ),
                            ),
                          );
                        }

                        final items = state.portal.mustamal;
                        if (items.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            child: Text(
                              l10n.homeNoProducts,
                              style: GoogleFonts.tajawal(
                                fontSize: 14.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 210.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(width: 14.w),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              // Mock distances for nearby display
                              final distances = ['٢ كم', '٥ كم', '٧ كم', '٣ كم', '١٠ كم'];
                              final distance = distances[index % distances.length];
                              return _NearbyCard(
                                item: item,
                                distance: distance,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.push('/mustamal/${item.id}', extra: item);
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── All Categories List ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
                  child: Text(
                    l10n.mustamalAllCategories,
                    style: GoogleFonts.tajawal(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                sliver: SliverList.separated(
                  itemCount: _allCategories.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) =>
                      _AllCategoryRow(cat: _allCategories[index]),
                ),
              ),
            ],
          ),
        ),

        // ── FAB ──────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/mustamal/create');
          },
          backgroundColor: _orange,
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }
}

// ── Location Chip ──────────────────────────────────────────────────────────

class _LocationChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _LocationChip({
    this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: trailing != null
              ? _orange.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: trailing != null
                ? _orange.withValues(alpha: 0.20)
                : AppTheme.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: _orange, size: 16.sp),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: trailing != null ? _orange : AppTheme.textPrimary,
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: 6.w),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Quick Category Tile ────────────────────────────────────────────────────

class _QuickCategoryTile extends StatelessWidget {
  final _CategoryItem cat;
  const _QuickCategoryTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: cat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: cat.color.withValues(alpha: 0.08)),
            ),
            child: Icon(cat.icon, color: cat.color, size: 26.sp),
          ),
          SizedBox(height: 5.h),
          Text(
            cat.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nearby Card ────────────────────────────────────────────────────────────

class _NearbyCard extends StatelessWidget {
  final dynamic item;
  final String distance;
  final VoidCallback onTap;

  const _NearbyCard({
    required this.item,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final images = (item.images as List<String>?) ?? [];
    final title = (item.title as String?) ?? '';
    final price = (item.price as num?) ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _orange.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: images.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          _PlaceholderBox(color: AppTheme.inactive.withValues(alpha: 0.15)),
                    )
                  else
                    _PlaceholderBox(color: AppTheme.inactive.withValues(alpha: 0.15)),
                  // Distance badge
                  PositionedDirectional(
                    bottom: 8.h,
                    end: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            distance,
                            style: GoogleFonts.tajawal(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.tajawal(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    IqdFormatter.format(price),
                    style: GoogleFonts.tajawal(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _orange,
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

// ── All Category Row ───────────────────────────────────────────────────────

class _AllCategoryRow extends StatelessWidget {
  final _AllCategoryItem cat;
  const _AllCategoryRow({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _orange.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(cat.icon, color: cat.color, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.label,
                    style: GoogleFonts.tajawal(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    cat.count,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: AppTheme.inactive,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder box ────────────────────────────────────────────────────────

class _PlaceholderBox extends StatelessWidget {
  final Color color;
  const _PlaceholderBox({required this.color});

  @override
  Widget build(BuildContext context) => Container(color: color);
}

// ── Data Models ────────────────────────────────────────────────────────────

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  const _CategoryItem({required this.icon, required this.label, required this.color});
}

class _AllCategoryItem {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  const _AllCategoryItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });
}
