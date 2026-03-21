import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../bloc/shops_cubit.dart';
import '../../data/models/shop_models.dart';

class MatajirCategoriesPage extends StatefulWidget {
  const MatajirCategoriesPage({super.key});

  @override
  State<MatajirCategoriesPage> createState() => _MatajirCategoriesPageState();
}

class _MatajirCategoriesPageState extends State<MatajirCategoriesPage> {
  late final CategoryCubit _categoryCubit;
  late final ShopsCubit _shopsCubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoryCubit = getIt<CategoryCubit>(param1: 'matajir')..fetchCategories();
    _shopsCubit = getIt<ShopsCubit>()..loadShops();
  }

  @override
  void dispose() {
    _categoryCubit.close();
    _shopsCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _categoryCubit),
        BlocProvider.value(value: _shopsCubit),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App Bar ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.matajirNavStores,
                          style: GoogleFonts.cairo(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.matajirBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Trust Bar ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.matajirBlue.withValues(alpha: 0.06),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_rounded,
                          color: AppTheme.success, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.matajirTrustBar,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search Bar ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Container(
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 14.w),
                        Icon(Icons.search_rounded,
                            color: AppTheme.textSecondary, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.matajirSearchHint,
                              hintStyle: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  color: AppTheme.textSecondary),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Featured Categories 3x3 ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                  child: Text(
                    l10n.matajirCategories,
                    style: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return state.maybeWhen(
                      loading: () => _CategoriesGridSkeleton(),
                      loaded: (categories, _, _) {
                        final cats = categories.take(9).toList();
                        if (cats.isEmpty) {
                          return _StaticCategoriesGrid(l10n: l10n);
                        }
                        return Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: cats.length,
                            itemBuilder: (context, i) {
                              final cat = cats[i];
                              return _CategoryGridCard(
                                label: cat.nameAr,
                                icon: _iconForSlug(cat.slug),
                                color: _colorForIndex(i),
                                onTap: () => context.push(
                                  '/search?category=${cat.slug}',
                                ),
                              );
                            },
                          ),
                        );
                      },
                      orElse: () => _StaticCategoriesGrid(l10n: l10n),
                    );
                  },
                ),
              ),

              // ── Popular Stores ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.matajirPopularStores,
                        style: GoogleFonts.cairo(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          l10n.matajirViewAll,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.matajirBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<ShopsCubit, ShopsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.shops.isEmpty) {
                      return _StoresRowSkeleton();
                    }
                    if (state.shops.isEmpty) return const SizedBox.shrink();
                    return SizedBox(
                      height: 110.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: state.shops.take(8).length,
                        separatorBuilder: (_, _) => SizedBox(width: 16.w),
                        itemBuilder: (context, i) {
                          final shop = state.shops[i];
                          return _PopularStoreCard(
                            shop: shop,
                            onTap: () => context.push(
                              '/matajir/shop/${shop.slug}?name=${Uri.encodeComponent(shop.name)}',
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // ── All Categories List ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Text(
                    l10n.matajirAllCategories,
                    style: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    final cats = state.maybeWhen(
                      loaded: (categories, _, _) => categories.isEmpty
                          ? _staticCategoryList(l10n)
                          : categories
                              .map((c) => _CatListItem(
                                    label: c.nameAr,
                                    icon: _iconForSlug(c.slug),
                                    count: null,
                                    onTap: () => context.push(
                                      '/search?category=${c.slug}',
                                    ),
                                  ))
                              .toList(),
                      orElse: () => _staticCategoryList(l10n),
                    );

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < cats.length; i++) ...[
                            cats[i],
                            if (i < cats.length - 1)
                              Divider(
                                height: 1,
                                color: AppTheme.divider,
                                indent: 16.w,
                                endIndent: 16.w,
                              ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 24.h)),
            ],
          ),
        ),
      ),
    );
  }

  List<_CatListItem> _staticCategoryList(AppLocalizations l10n) => [
        _CatListItem(
          label: l10n.matajirCatElectronics,
          icon: Icons.devices_rounded,
          count: '٤,٢٣١',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatFashion,
          icon: Icons.checkroom_rounded,
          count: '٨,١٥٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatHome,
          icon: Icons.kitchen_rounded,
          count: '٢,٨٤٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatMobiles,
          icon: Icons.smartphone_rounded,
          count: '١,٦٢٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatLaptops,
          icon: Icons.laptop_mac_rounded,
          count: '٩٤٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatSports,
          icon: Icons.sports_soccer_rounded,
          count: '٥٧٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatFurniture,
          icon: Icons.chair_rounded,
          count: '١,١٣٠',
          onTap: () {},
        ),
        _CatListItem(
          label: l10n.matajirCatCars,
          icon: Icons.directions_car_rounded,
          count: '٨٢٠',
          onTap: () {},
        ),
      ];
}

// ── Static Categories Grid (fallback when API returns empty) ──────────────

class _StaticCategoriesGrid extends StatelessWidget {
  final AppLocalizations l10n;
  const _StaticCategoriesGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final items = [
      (l10n.matajirCatPhones, Icons.smartphone_rounded, 0),
      (l10n.matajirCatLaptops, Icons.laptop_mac_rounded, 0),
      (l10n.matajirCatTVs, Icons.tv_rounded, 0),
      (l10n.matajirCatAppliances, Icons.blender_rounded, 3),
      (l10n.matajirCatFashion, Icons.checkroom_rounded, 4),
      (l10n.matajirCatFurniture, Icons.chair_rounded, 5),
      (l10n.matajirCatCars, Icons.directions_car_rounded, 6),
      (l10n.matajirCatSports, Icons.sports_soccer_rounded, 7),
      (l10n.matajirCatBooks, Icons.menu_book_rounded, 8),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.9,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final (label, icon, colorIdx) = items[i];
          return _CategoryGridCard(
            label: label,
            icon: icon,
            color: _colorForIndex(colorIdx),
            onTap: () {},
          );
        },
      ),
    );
  }
}

// ── Category Grid Card ────────────────────────────────────────────────────

class _CategoryGridCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryGridCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Popular Store Card ────────────────────────────────────────────────────

class _PopularStoreCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const _PopularStoreCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: shop.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            shop.name.isNotEmpty
                                ? shop.name[0].toUpperCase()
                                : 'S',
                            style: GoogleFonts.cairo(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 10.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              shop.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
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

// ── All-Categories List Item ───────────────────────────────────────────────

class _CatListItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? count;
  final VoidCallback onTap;

  const _CatListItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: AppTheme.matajirBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.matajirBlue, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (count != null)
                    Text(
                      '$count ${l10n.matajirProductSuffix}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded,
                color: AppTheme.textSecondary, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

// ── Skeletons ─────────────────────────────────────────────────────────────

class _CategoriesGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.9,
        ),
        itemCount: 9,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: AppTheme.shimmerBase,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
      ),
    );
  }
}

class _StoresRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        separatorBuilder: (_, _) => SizedBox(width: 16.w),
        itemBuilder: (_, _) => Column(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                color: AppTheme.shimmerBase,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: 50.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: AppTheme.shimmerBase,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

IconData _iconForSlug(String slug) {
  final s = slug.toLowerCase();
  if (s.contains('phone') || s.contains('mobile') || s.contains('هاتف')) {
    return Icons.smartphone_rounded;
  }
  if (s.contains('laptop') || s.contains('computer')) {
    return Icons.laptop_mac_rounded;
  }
  if (s.contains('tv') || s.contains('television')) return Icons.tv_rounded;
  if (s.contains('cloth') || s.contains('fashion') || s.contains('ملابس')) {
    return Icons.checkroom_rounded;
  }
  if (s.contains('home') || s.contains('kitchen') || s.contains('منزل')) {
    return Icons.kitchen_rounded;
  }
  if (s.contains('sport') || s.contains('رياضة')) {
    return Icons.sports_soccer_rounded;
  }
  if (s.contains('car') || s.contains('auto')) {
    return Icons.directions_car_rounded;
  }
  if (s.contains('book') || s.contains('كتاب')) {
    return Icons.menu_book_rounded;
  }
  if (s.contains('furniture') || s.contains('أثاث')) {
    return Icons.chair_rounded;
  }
  if (s.contains('electronic') || s.contains('إلكترون')) {
    return Icons.devices_rounded;
  }
  return Icons.category_rounded;
}

Color _colorForIndex(int i) {
  const colors = [
    Color(0xFF1B4FD8), // blue
    Color(0xFF1B4FD8), // blue
    Color(0xFF1B4FD8), // blue
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
    Color(0xFFF97316), // orange
    Color(0xFF6B7280), // slate
    Color(0xFF22C55E), // green
    Color(0xFF8B5CF6), // purple
  ];
  return colors[i % colors.length];
}
