import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../map/presentation/pages/mahallati_page.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../../cart/presentation/pages/cart_conflict_sheet.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../data/models/shop_models.dart';

class MatajirPage extends StatefulWidget {
  const MatajirPage({super.key});

  @override
  State<MatajirPage> createState() => _MatajirPageState();
}

class _MatajirPageState extends State<MatajirPage> {
  late final HomeCubit _cubit;
  late final CategoryCubit _categoryCubit;
  bool _mapMode = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
    _categoryCubit = getIt<CategoryCubit>(param1: 'matajir')..fetchCategories();
  }

  @override
  void dispose() {
    _cubit.close();
    _categoryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _categoryCubit),
      ],
      child: BlocListener<MatajirCartCubit, CartState>(
        listenWhen: (prev, curr) =>
            curr.cartStatus == CartStatus.conflict &&
            prev.cartStatus != CartStatus.conflict,
        listener: (context, state) {
          CartConflictSheet.show(context, context.read<MatajirCartCubit>());
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F6F8),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── App Bar ─────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _MatajirAppBar(l10n: l10n),
                    ),

                    // ── Trust Bar ────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppTheme.success.withValues(alpha: 0.08),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: AppTheme.success, size: 15.sp),
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

                    // ── Search Bar ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                        child: GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(color: AppTheme.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 14.w),
                                Icon(Icons.search_rounded,
                                    color: AppTheme.textSecondary, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  l10n.matajirSearchHint,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Map / List Toggle ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text('☰ قائمة', style: GoogleFonts.cairo(fontSize: 12.sp)),
                              selected: !_mapMode,
                              onSelected: (_) => setState(() => _mapMode = false),
                              selectedColor: AppTheme.matajirBlue.withValues(alpha: 0.15),
                            ),
                            SizedBox(width: 8.w),
                            ChoiceChip(
                              label: Text('🗺 محلتي', style: GoogleFonts.cairo(fontSize: 12.sp)),
                              selected: _mapMode,
                              onSelected: (_) => setState(() => _mapMode = true),
                              selectedColor: AppTheme.matajirBlue.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Category Filter Chips ────────────────────────────
                    if (!_mapMode)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 48.h,
                        child: BlocBuilder<CategoryCubit, CategoryState>(
                          builder: (context, state) {
                            return state.maybeWhen(
                              loaded: (categories, p2, p3) =>
                                  _CategoryChips(categories: categories),
                              orElse: () =>
                                  const _CategoryChips(categories: []),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── Map View (when toggle active) ────────────────────
                    if (_mapMode)
                    const SliverFillRemaining(
                      child: MahallatiPage(contextFilter: 'matajir'),
                    ),

                    // ── Promo Banner ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                        child: const _PromoBanner(),
                      ),
                    ),

                    // ── Verified Stores Row ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.matajirVerifiedStores,
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
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final shops = state.shopCatalogs
                              .map((c) => c.shop)
                              .toList();
                          if (state.isLoading && shops.isEmpty) {
                            return _VerifiedStoresSkeleton();
                          }
                          return _VerifiedStoresRow(shops: shops);
                        },
                      ),
                    ),

                    // ── Featured Products ────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
                        child: Text(
                          l10n.matajirFeaturedProducts,
                          style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        final products = state.shopCatalogs
                            .expand((c) => c.products)
                            .toList();

                        if (state.isLoading && products.isEmpty) {
                          return const SliverProductGridSkeleton();
                        }

                        if (products.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 48.h, horizontal: 32.w),
                              child: Center(
                                child: Text(
                                  l10n.matajirShopEmpty,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              16.w, 0, 16.w, 120.h),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14.h,
                              crossAxisSpacing: 14.w,
                              childAspectRatio: 0.58,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _MatajirProductCard(
                                  item: products[index]),
                              childCount: products.length,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // ── Floating Cart Peek Bar ───────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<MatajirCartCubit, CartState>(
                    builder: (context, cartState) {
                      if (cartState.cartCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return _CartPeekBar(
                        count: cartState.cartCount,
                        total: cartState.cartTotal,
                        l10n: l10n,
                        onTap: () => context.push('/matajir/cart'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── App Bar ────────────────────────────────────────────────────────────────

class _MatajirAppBar extends StatelessWidget {
  final AppLocalizations l10n;
  const _MatajirAppBar({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: 36.w,
              height: 36.w,
              margin: EdgeInsetsDirectional.only(end: 8.w),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.home_rounded, size: 20.sp, color: AppTheme.matajirBlue),
            ),
          ),
          Expanded(
            child: Text(
              l10n.matajirTitle,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.matajirBlue,
              ),
            ),
          ),
          BlocBuilder<MatajirCartCubit, CartState>(
            builder: (context, cartState) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => context.push('/matajir/cart'),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_rounded,
                          size: 20.sp, color: AppTheme.textPrimary),
                    ),
                  ),
                  if (cartState.cartCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '${cartState.cartCount}',
                            style: GoogleFonts.cairo(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => context.push('/favorites'),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_border_rounded,
                  size: 20.sp, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Filter Chips ──────────────────────────────────────────────────

class _CategoryChips extends StatefulWidget {
  final List categories;
  const _CategoryChips({required this.categories});

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = widget.categories.isEmpty
        ? [
            l10n.matajirFilterAll,
            l10n.matajirCatMobiles,
            l10n.matajirCatLaptops,
            l10n.matajirCatElectronics,
            l10n.matajirCatTVs,
          ]
        : [l10n.matajirFilterAll, ...widget.categories.map((c) => c.nameAr)];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: labels.length,
      separatorBuilder: (_, i2) => SizedBox(width: 8.w),
      itemBuilder: (context, i) {
        final selected = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: selected ? AppTheme.matajirBlue : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: selected ? AppTheme.matajirBlue : AppTheme.divider,
              ),
            ),
            child: Center(
              child: Text(
                labels[i],
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Promo Banner with countdown ────────────────────────────────────────────

class _PromoBanner extends StatefulWidget {
  const _PromoBanner();

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  late Duration _remaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Promo ends in ~4h 23m from now (illustrative)
    _remaining = const Duration(hours: 4, minutes: 23, seconds: 10);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));

    return Container(
      height: 88.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4FD8), Color(0xFF60A5FA)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.matajirBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -12,
            top: -12,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.matajirPromoToday,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                color: Colors.white, size: 13.sp),
                            SizedBox(width: 4.w),
                            Text(
                              '${l10n.matajirPromoEndsIn} $h:$m:$s',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    '٪٣٠',
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.matajirBlue,
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

// ── Verified Stores Row ────────────────────────────────────────────────────

class _VerifiedStoresRow extends StatelessWidget {
  final List<ShopModel> shops;
  const _VerifiedStoresRow({required this.shops});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: shops.isEmpty ? 5 : shops.length,
        separatorBuilder: (_, i2) => SizedBox(width: 16.w),
        itemBuilder: (context, i) {
          if (shops.isEmpty) {
            return _VerifiedStoreAvatar(shop: null, onTap: () {});
          }
          final shop = shops[i];
          return _VerifiedStoreAvatar(
            shop: shop,
            onTap: () => context.push(
              '/matajir/shop/${shop.slug}?name=${Uri.encodeComponent(shop.name)}',
            ),
          );
        },
      ),
    );
  }
}

class _VerifiedStoreAvatar extends StatelessWidget {
  final ShopModel? shop;
  final VoidCallback onTap;
  const _VerifiedStoreAvatar({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = shop?.name ?? '';
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 62.w,
                  height: 62.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.divider, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: shop?.imageUrl != null && shop!.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: shop!.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'S',
                            style: GoogleFonts.cairo(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: -1,
                  left: -1,
                  child: Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child:
                        Icon(Icons.check_rounded, size: 10.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              name.isEmpty ? '—' : name,
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

// ── Product Card ───────────────────────────────────────────────────────────

class _MatajirProductCard extends StatelessWidget {
  final ProductModel item;
  const _MatajirProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => context.push('/matajir/product/${item.id}', extra: item),
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                  if (item.images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      placeholder: (_, i2) =>
                          Container(color: AppTheme.shimmerBase),
                    )
                  else
                    Container(color: AppTheme.shimmerBase),
                  // Favourite button
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_border_rounded,
                          size: 15.sp, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verified store badge
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: AppTheme.success, size: 10.sp),
                        SizedBox(width: 3.w),
                        Text(
                          l10n.matajirVerifiedBadge,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price + lock icon
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            IqdFormatter.format(item.price),
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                        ),
                        Icon(Icons.lock_rounded,
                            color: AppTheme.success, size: 16.sp),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Add to cart button
                    BlocBuilder<MatajirCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        final inCart = cartState.isInCart(item.id);
                        return GestureDetector(
                          onTap: () =>
                              ctx.read<MatajirCartCubit>().addToCart(item),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: inCart
                                  ? AppTheme.divider
                                  : AppTheme.matajirBlue,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  inCart
                                      ? Icons.check_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  size: 14.sp,
                                  color: inCart
                                      ? AppTheme.textPrimary
                                      : Colors.white,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  inCart
                                      ? l10n.matajirInCart
                                      : l10n.matajirAddToCart,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: inCart
                                        ? AppTheme.textPrimary
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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

// ── Floating Cart Peek Bar ─────────────────────────────────────────────────

class _CartPeekBar extends StatelessWidget {
  final int count;
  final double total;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _CartPeekBar({
    required this.count,
    required this.total,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.shopping_bag_rounded,
                          size: 20.sp, color: AppTheme.matajirBlue),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: AppTheme.matajirBlue,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: GoogleFonts.cairo(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.matajirProductCount(count),
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: Colors.white60,
                        ),
                      ),
                      Text(
                        IqdFormatter.format(total),
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      l10n.matajirCompleteOrder,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.matajirBlue,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14.sp, color: AppTheme.matajirBlue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Skeletons ──────────────────────────────────────────────────────────────

class _VerifiedStoresSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        separatorBuilder: (_, i2) => SizedBox(width: 16.w),
        itemBuilder: (_, i2) => Column(
          children: [
            Container(
              width: 62.w,
              height: 62.w,
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
