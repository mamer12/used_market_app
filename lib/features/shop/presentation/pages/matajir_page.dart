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
import '../../../cart/presentation/widgets/cart_conflict_sheet.dart';
import '../../../category/presentation/cubit/category_cubit.dart';
import '../../../category/presentation/cubit/category_state.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../data/models/shop_models.dart';

// ── Constants ───────────────────────────────────────────────────────────────

const _kMatajirBlue  = AppTheme.matajirBlue;         // #1B4FD8
const _kMatajirGreen = Color(0xFF00B37E);             // #00B37E
const _kGold         = Color(0xFFFFD700);
const _kBg           = Color(0xFFFAFAFA);

// ── Story ring mock data ─────────────────────────────────────────────────────

const _kStoryShops = [
  'عالم الحد',
  'أزياء النور',
  'تيكو سنور',
  'جمالك',
  'بوتيك',
];

// ── Flash deal mock data ─────────────────────────────────────────────────────

class _FlashDeal {
  final String name;
  final int price;
  final int originalPrice;
  final int discountPct;
  const _FlashDeal({
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discountPct,
  });
}

const _kFlashDeals = [
  _FlashDeal(name: 'سماعات بلوتوث', price: 45000, originalPrice: 56250, discountPct: 20),
  _FlashDeal(name: 'حقيبة جلدية', price: 85000, originalPrice: 100000, discountPct: 15),
  _FlashDeal(name: 'ساعة ذكية', price: 120000, originalPrice: 200000, discountPct: 40),
  _FlashDeal(name: 'عطر فاخر', price: 35000, originalPrice: 58333, discountPct: 40),
];

// ── Category mock data ───────────────────────────────────────────────────────

class _Category {
  final IconData icon;
  final String label;
  const _Category(this.icon, this.label);
}

const _kCategories = [
  _Category(Icons.devices_rounded,       'إلكترونيات'),
  _Category(Icons.man_rounded,           'أزياء رجالي'),
  _Category(Icons.woman_rounded,         'أزياء نسائي'),
  _Category(Icons.hiking_rounded,        'أحذية'),
  _Category(Icons.work_outline_rounded,  'حقائب'),
  _Category(Icons.spa_rounded,           'مستحضرات'),
  _Category(Icons.child_care_rounded,    'أطفال'),
  _Category(Icons.more_horiz_rounded,    'المزيد'),
];

// ═══════════════════════════════════════════════════════════════════════════
// MatajirPage
// ═══════════════════════════════════════════════════════════════════════════

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
          CartConflictSheet.show(context);
        },
        child: Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ── AppBar ─────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _MatajirAppBar(l10n: l10n),
                    ),

                    // ── Search Bar ─────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _SearchBar(
                        onTap: () => context.push('/search'),
                      ),
                    ),

                    // ── Story Rings ────────────────────────────────────────
                    const SliverToBoxAdapter(child: _StoryRingsRow()),

                    // ── حار ومكسب Flash Deals ──────────────────────────────
                    const SliverToBoxAdapter(child: _HarWaMaksabStrip()),

                    // ── Map / List Toggle ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text('☰ قائمة',
                                  style: GoogleFonts.cairo(fontSize: 12.sp)),
                              selected: !_mapMode,
                              onSelected: (_) =>
                                  setState(() => _mapMode = false),
                              selectedColor:
                                  _kMatajirBlue.withValues(alpha: 0.15),
                            ),
                            SizedBox(width: 8.w),
                            ChoiceChip(
                              label: Text('🗺 محلتي',
                                  style: GoogleFonts.cairo(fontSize: 12.sp)),
                              selected: _mapMode,
                              onSelected: (_) =>
                                  setState(() => _mapMode = true),
                              selectedColor:
                                  _kMatajirBlue.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Category Chips ─────────────────────────────────────
                    if (!_mapMode)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 52.h,
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

                    // ── Map View ───────────────────────────────────────────
                    if (_mapMode)
                      const SliverFillRemaining(
                        child: MahallatiPage(contextFilter: 'matajir'),
                      ),

                    // ── Section: منتجات مميزة ──────────────────────────────
                    if (!_mapMode) ...[
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: l10n.matajirFeaturedProducts,
                          actionLabel: l10n.matajirViewAll,
                          onAction: () {},
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
                            padding:
                                EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 14.h,
                                crossAxisSpacing: 14.w,
                                childAspectRatio: 0.58,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _ProductCard(
                                    item: products[index]),
                                childCount: products.length,
                              ),
                            ),
                          );
                        },
                      ),

                      // ── Section: متاجر رائجة ─────────────────────────────
                      SliverToBoxAdapter(
                        child: _SectionHeader(
                          title: l10n.matajirVerifiedStores,
                          actionLabel: l10n.matajirViewAll,
                          onAction: () {},
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
                            return _TrendingShopsRow(shops: shops);
                          },
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: 120.h),
                      ),
                    ],
                  ],
                ),

                // ── Floating Cart Peek Bar ─────────────────────────────────
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

// ═══════════════════════════════════════════════════════════════════════════
// _MatajirAppBar
// ═══════════════════════════════════════════════════════════════════════════

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
          // Avatar circle (left per RTL)
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: AppTheme.matajirBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  size: 20.sp, color: _kMatajirBlue),
            ),
          ),
          SizedBox(width: 8.w),
          // Title
          Expanded(
            child: Text(
              l10n.matajirTitle,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: _kMatajirBlue,
              ),
            ),
          ),
          // Cart icon with badge
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
                        color: AppTheme.matajirBlueSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_rounded,
                          size: 20.sp, color: _kMatajirBlue),
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
                color: AppTheme.matajirBlueSurface,
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

// ═══════════════════════════════════════════════════════════════════════════
// _SearchBar
// ═══════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: const Color(0xFFE3D8D1)),
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
              Icon(Icons.camera_alt_outlined,
                  color: AppTheme.textSecondary, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'ابحث عن منتج أو متجر...',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Icon(Icons.search_rounded,
                  color: _kMatajirBlue, size: 22.sp),
              SizedBox(width: 14.w),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _StoryRingsRow
// ═══════════════════════════════════════════════════════════════════════════

class _StoryRingsRow extends StatelessWidget {
  const _StoryRingsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: _kStoryShops.length + 1, // +1 for "+" button
        separatorBuilder: (context, index) => SizedBox(width: 14.w),
        itemBuilder: (context, i) {
          if (i == _kStoryShops.length) {
            return const _AddStoryButton();
          }
          return _StoryRing(label: _kStoryShops[i]);
        },
      ),
    );
  }
}

class _StoryRing extends StatelessWidget {
  final String label;
  const _StoryRing({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 62.w,
        child: Column(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kMatajirBlue, width: 2.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.matajirBlueSurface,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      label.isNotEmpty ? label[0] : 'م',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: _kMatajirBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
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

class _AddStoryButton extends StatelessWidget {
  const _AddStoryButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62.w,
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _kMatajirBlue,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Icon(Icons.add_rounded,
                  color: _kMatajirBlue, size: 26.sp),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'إضافة',
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _HarWaMaksabStrip  (حار ومكسب flash deals)
// ═══════════════════════════════════════════════════════════════════════════

class _HarWaMaksabStrip extends StatefulWidget {
  const _HarWaMaksabStrip();

  @override
  State<_HarWaMaksabStrip> createState() => _HarWaMaksabStripState();
}

class _HarWaMaksabStripState extends State<_HarWaMaksabStrip> {
  late Duration _remaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remaining = const Duration(hours: 3, minutes: 22);
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
    final h = _pad(_remaining.inHours);
    final m = _pad(_remaining.inMinutes.remainder(60));
    final s = _pad(_remaining.inSeconds.remainder(60));

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: _kMatajirBlue,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: _kMatajirBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Countdown
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          color: _kGold, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'بنتهي خلال $h:$m:$s',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _kGold,
                        ),
                      ),
                    ],
                  ),
                  // Title right-aligned
                  Text(
                    'حار ومكسب 🔥',
                    style: GoogleFonts.cairo(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            // Product cards 2-col grid
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 1.7,
                ),
                itemCount: _kFlashDeals.length,
                itemBuilder: (_, i) => _FlashDealCard(deal: _kFlashDeals[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashDealCard extends StatelessWidget {
  final _FlashDeal deal;
  const _FlashDealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      padding: EdgeInsets.all(8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Discount badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '-%${deal.discountPct}',
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  deal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  IqdFormatter.format(deal.price),
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: _kMatajirGreen,
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

// ═══════════════════════════════════════════════════════════════════════════
// _CategoryChips
// ═══════════════════════════════════════════════════════════════════════════

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
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      itemCount: _kCategories.length,
      separatorBuilder: (context, index) => SizedBox(width: 8.w),
      itemBuilder: (context, i) {
        final cat = _kCategories[i];
        final selected = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: selected ? _kMatajirBlue : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: selected ? _kMatajirBlue : AppTheme.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 14.sp,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  cat.label,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _SectionHeader
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: _kMatajirBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _ProductCard  (منتجات مميزة)
// ═══════════════════════════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget {
  final ProductModel item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
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
            // Image area
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.images.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppTheme.shimmerBase),
                    )
                  else
                    Container(color: AppTheme.shimmerBase),
                  // Favorite heart
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
                  // مضمون ✓ badge
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: _kMatajirGreen,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'مضمون ✓',
                        style: GoogleFonts.cairo(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info area
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    // Price
                    Text(
                      IqdFormatter.format(item.price),
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: _kMatajirBlue,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Add to cart
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
                              color:
                                  inCart ? AppTheme.divider : _kMatajirBlue,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull),
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
                                      ? AppLocalizations.of(ctx)
                                          .matajirInCart
                                      : AppLocalizations.of(ctx)
                                          .matajirAddToCart,
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

// ═══════════════════════════════════════════════════════════════════════════
// _TrendingShopsRow  (متاجر رائجة)
// ═══════════════════════════════════════════════════════════════════════════

class _TrendingShopsRow extends StatelessWidget {
  final List<ShopModel> shops;
  const _TrendingShopsRow({required this.shops});

  @override
  Widget build(BuildContext context) {
    final count = shops.isEmpty ? 5 : shops.length;
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: count,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, i) {
          if (shops.isEmpty) {
            return _TrendingShopCard(shop: null, onTap: () {});
          }
          final shop = shops[i];
          return _TrendingShopCard(
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

class _TrendingShopCard extends StatelessWidget {
  final ShopModel? shop;
  final VoidCallback onTap;
  const _TrendingShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = shop?.name ?? '—';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar with ring
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kMatajirBlue, width: 2),
                color: AppTheme.matajirBlueSurface,
              ),
              clipBehavior: Clip.antiAlias,
              child: shop?.imageUrl != null && shop!.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop!.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        name.isNotEmpty ? name[0] : 'م',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _kMatajirBlue,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            // Follow button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.matajirBlueSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: _kMatajirBlue),
              ),
              child: Text(
                'متابعة',
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: _kMatajirBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _CartPeekBar
// ═══════════════════════════════════════════════════════════════════════════

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
                          size: 20.sp, color: _kMatajirBlue),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: _kMatajirBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
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
                        color: _kMatajirBlue,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14.sp, color: _kMatajirBlue),
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

// ═══════════════════════════════════════════════════════════════════════════
// _VerifiedStoresSkeleton
// ═══════════════════════════════════════════════════════════════════════════

class _VerifiedStoresSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) => Container(
          width: 120.w,
          decoration: BoxDecoration(
            color: AppTheme.shimmerBase,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
      ),
    );
  }
}
