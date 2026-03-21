import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../data/models/shop_models.dart';
import '../bloc/shops_cubit.dart';

// ── Matajir design tokens ──────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAFA);
const _kSurface = Colors.white;
const _kBorder = Color(0xFFEDE6DC);
const _kPrimary = Color(0xFF1B4FD8);
const _kGreen = Color(0xFF00B37E);
const _kTextPrimary = Color(0xFF1C1713);
const _kTextSecondary = Color(0xFF6B5E52);

class ShopProductsPage extends StatefulWidget {
  final String shopSlug;
  final String shopName;

  const ShopProductsPage({
    super.key,
    required this.shopSlug,
    required this.shopName,
  });

  @override
  State<ShopProductsPage> createState() => _ShopProductsPageState();
}

class _ShopProductsPageState extends State<ShopProductsPage> {
  late final ShopProductsCubit _cubit;
  final _scrollController = ScrollController();

  int _selectedCategoryIndex = 0;
  bool _isGridView = true;
  String _sortValue = 'newest';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ShopProductsCubit>()..loadCatalog(widget.shopSlug);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _cubit.loadCatalog(widget.shopSlug);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Shop Header (floating SliverAppBar wrapping the header) ──
            BlocBuilder<ShopProductsCubit, ShopProductsState>(
              builder: (context, state) {
                return SliverToBoxAdapter(
                  child: _ShopHeader(
                    shop: state.shop,
                    fallbackName: widget.shopName,
                  ),
                );
              },
            ),

            // ── Category chips (pinned) ───────────────────────────────────
            BlocBuilder<ShopProductsCubit, ShopProductsState>(
              builder: (context, state) {
                final categories = _buildCategories(state);
                return SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryChipsDelegate(
                    categories: categories,
                    selectedIndex: _selectedCategoryIndex,
                    onSelected: (i) =>
                        setState(() => _selectedCategoryIndex = i),
                  ),
                );
              },
            ),

            // ── Filter / sort row ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterSortRow(
                isGridView: _isGridView,
                sortValue: _sortValue,
                onToggleView: () =>
                    setState(() => _isGridView = !_isGridView),
                onSortChanged: (v) => setState(() => _sortValue = v),
              ),
            ),

            // ── Products ─────────────────────────────────────────────────
            BlocBuilder<ShopProductsCubit, ShopProductsState>(
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const SliverProductGridSkeleton();
                }
                if (state.error != null && state.products.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildError(context, state.error!, l10n),
                  );
                }
                if (state.products.isEmpty) {
                  return SliverFillRemaining(child: _buildEmpty(l10n));
                }
                return _isGridView
                    ? _buildProductsGrid(context, state, l10n)
                    : _buildProductsList(context, state, l10n);
              },
            ),
          ],
        ),
        bottomNavigationBar: BlocBuilder<MatajirCartCubit, CartState>(
          builder: (context, cartState) {
            if (cartState.cartCount == 0) return const SizedBox.shrink();
            return _CartBar(
              count: cartState.cartCount,
              total: cartState.cartTotal,
              l10n: l10n,
              onTap: () => context.push('/matajir/cart'),
            );
          },
        ),
      ),
    );
  }

  List<String> _buildCategories(ShopProductsState state) {
    // Base "all" label + any unique categories on products
    final cats = <String>['الكل'];
    if (state.products.isNotEmpty) {
      final seen = <String>{};
      for (final p in state.products) {
        if (p.description != null && p.description!.isNotEmpty) {
          // category is not on ProductModel; using sales unit as secondary filter
        }
      }
      // static fallback categories relevant to Matajir
      if (seen.isEmpty) {
        cats.addAll(['إلكترونيات', 'ملابس', 'منزل', 'رياضة']);
      } else {
        cats.addAll(seen);
      }
    }
    return cats;
  }

  Widget _buildProductsGrid(
    BuildContext context,
    ShopProductsState state,
    AppLocalizations l10n,
  ) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.products.length) {
              return Padding(
                padding: EdgeInsets.all(20.w),
                child: const Center(
                  child:
                      CircularProgressIndicator(color: _kPrimary),
                ),
              );
            }
            return _StoreProductCard(product: state.products[index]);
          },
          childCount:
              state.products.length + (state.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildProductsList(
    BuildContext context,
    ShopProductsState state,
    AppLocalizations l10n,
  ) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      sliver: SliverList.separated(
        itemCount:
            state.products.length + (state.isLoading ? 1 : 0),
        separatorBuilder: (_, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == state.products.length) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: _kPrimary),
              ),
            );
          }
          return _StoreProductListTile(
              product: state.products[index]);
        },
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              color: _kSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 32.sp, color: _kTextSecondary),
          ),
          SizedBox(height: 14.h),
          Text(
            l10n.matajirShopEmpty,
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.matajirShopEmptySubtitle,
            style: GoogleFonts.cairo(
                fontSize: 13.sp, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppTheme.error),
          SizedBox(height: 12.h),
          Text(message,
              style: GoogleFonts.cairo(
                  fontSize: 14.sp, color: _kTextSecondary)),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _cubit.loadCatalog(widget.shopSlug, refresh: true),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                l10n.matajirRetry,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shop Header ──────────────────────────────────────────────────────────────

class _ShopHeader extends StatefulWidget {
  final ShopModel? shop;
  final String fallbackName;

  const _ShopHeader({required this.shop, required this.fallbackName});

  @override
  State<_ShopHeader> createState() => _ShopHeaderState();
}

class _ShopHeaderState extends State<_ShopHeader> {
  bool _isFollowing = false;
  bool _followLoading = false;

  ShopModel? get shop => widget.shop;
  String get _name => shop?.name ?? widget.fallbackName;

  Future<void> _toggleFollow() async {
    if (_followLoading || shop == null) return;
    setState(() => _followLoading = true);
    try {
      final dio = getIt<Dio>();
      final endpoint = '${ApiConstants.shops}/${shop!.id}/follow';
      final res = _isFollowing
          ? await dio.delete<void>(endpoint)
          : await dio.post<void>(endpoint);
      final code = res.statusCode ?? 0;
      if (code == 200 || code == 201 || code == 204) {
        if (mounted) setState(() => _isFollowing = !_isFollowing);
      }
    } catch (_) {}
    if (mounted) setState(() => _followLoading = false);
  }

  Future<void> _openChat() async {
    // Message action — navigate or show bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = shop?.verificationStatus == 'verified';
    final followers = 0; // placeholder until API exposes follower counts
    final products = 0; // placeholder
    final sales = 0; // placeholder

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            // ── Banner ─────────────────────────────────────────────────
            SizedBox(
              height: 160.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Banner image
                  shop?.storefrontUrl != null &&
                          shop!.storefrontUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: shop!.storefrontUrl!,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(
                            color: AppTheme.matajirBlueSurface,
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            color: AppTheme.matajirBlueSurface,
                          ),
                        )
                      : Container(
                          color: AppTheme.matajirBlueSurface,
                          child: Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 48.sp,
                              color: _kPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                  // Dark gradient overlay — bottom → transparent top
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── White info card below banner ───────────────────────────
            Container(
              color: _kSurface,
              padding: EdgeInsets.fromLTRB(16.w, 44.h, 16.w, 16.h),
              child: Column(
                children: [
                  // Shop name
                  Text(
                    _name,
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),

                  // Verified badge
                  if (isVerified) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _kGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: _kGreen, size: 13.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'متجر موثق ✓',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ] else
                    SizedBox(height: 12.h),

                  // Stats row: followers | products | sales
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatItem(label: 'متابع', value: '$followers'),
                        _StatDivider(),
                        _StatItem(label: 'منتج', value: '$products'),
                        _StatDivider(),
                        _StatItem(label: 'مبيعات', value: '$sales'),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Follow + Message buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Follow button
                      GestureDetector(
                        onTap: _followLoading ? null : _toggleFollow,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 38.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: _isFollowing
                                ? _kPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: _kPrimary,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: _followLoading
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _isFollowing
                                          ? Colors.white
                                          : _kPrimary,
                                    ),
                                  )
                                : Text(
                                    _isFollowing ? 'متابَع ✓' : 'متابعة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: _isFollowing
                                          ? Colors.white
                                          : _kPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Message button
                      GestureDetector(
                        onTap: _openChat,
                        child: Container(
                          height: 38.h,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(999.r),
                            border:
                                Border.all(color: _kBorder, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              'رسالة',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _kTextPrimary,
                              ),
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

        // Back button (top-right in RTL)
        Positioned(
          top: 12.h,
          right: 12.w,
          child: GestureDetector(
            onTap: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: _kTextPrimary,
              ),
            ),
          ),
        ),

        // Overlapping avatar circle
        Positioned(
          top: 160.h - 36.w, // banner height − half avatar
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kSurface,
                border: Border.all(color: _kSurface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: shop?.imageUrl != null &&
                      shop!.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: shop!.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        _name.isNotEmpty
                            ? _name[0].toUpperCase()
                            : 'S',
                        style: GoogleFonts.cairo(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat Item / Divider ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            color: _kTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: _kBorder,
    );
  }
}

// ── Category Chips Delegate ───────────────────────────────────────────────────

class _CategoryChipsDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryChipsDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _kSurface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: categories.length,
        separatorBuilder: (_, i) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: selected ? _kPrimary : _kSurface,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: selected ? _kPrimary : _kBorder,
                ),
              ),
              child: Center(
                child: Text(
                  categories[i],
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _kTextSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryChipsDelegate old) =>
      old.selectedIndex != selectedIndex ||
      old.categories.length != categories.length;
}

// ── Filter / Sort Row ─────────────────────────────────────────────────────────

class _FilterSortRow extends StatelessWidget {
  final bool isGridView;
  final String sortValue;
  final VoidCallback onToggleView;
  final ValueChanged<String> onSortChanged;

  const _FilterSortRow({
    required this.isGridView,
    required this.sortValue,
    required this.onToggleView,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          // Sort dropdown
          Expanded(
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _kBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sortValue,
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      size: 18.sp, color: _kTextSecondary),
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: _kTextPrimary,
                  ),
                  onChanged: (v) {
                    if (v != null) onSortChanged(v);
                  },
                  items: const [
                    DropdownMenuItem(
                        value: 'newest', child: Text('الأحدث')),
                    DropdownMenuItem(
                        value: 'price_asc', child: Text('الأقل سعراً')),
                    DropdownMenuItem(
                        value: 'price_desc', child: Text('الأعلى سعراً')),
                    DropdownMenuItem(
                        value: 'popular', child: Text('الأكثر شيوعاً')),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Grid / list toggle
          GestureDetector(
            onTap: onToggleView,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: _kBorder),
              ),
              child: Icon(
                isGridView
                    ? Icons.view_list_rounded
                    : Icons.grid_view_rounded,
                size: 18.sp,
                color: _kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Store Product Card (Grid) ─────────────────────────────────────────────────

class _StoreProductCard extends StatelessWidget {
  final ProductModel product;
  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () =>
          context.push('/matajir/product/${product.id}', extra: product),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
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
                  product.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) =>
                              Container(color: AppTheme.shimmerBase),
                        )
                      : Container(color: AppTheme.shimmerBase),
                  // Wishlist button
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_border_rounded,
                          size: 14.sp, color: _kTextSecondary),
                    ),
                  ),
                  if (!product.isActive)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppTheme.inactive,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            l10n.matajirOutOfStock,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
                    // Madhmoon badge
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: _kGreen, size: 10.sp),
                        SizedBox(width: 3.w),
                        Text(
                          'مضمون ✓',
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            color: _kGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Name
                    Text(
                      product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Price + lock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            IqdFormatter.format(product.price),
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                        Icon(Icons.lock_rounded,
                            color: _kGreen, size: 14.sp),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Add to cart button
                    BlocBuilder<MatajirCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        final inCart = cartState.isInCart(product.id);
                        return GestureDetector(
                          onTap: () => ctx
                              .read<MatajirCartCubit>()
                              .addToCart(product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: inCart ? _kBorder : _kPrimary,
                              borderRadius:
                                  BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  inCart
                                      ? Icons.check_rounded
                                      : Icons.add_shopping_cart_rounded,
                                  size: 13.sp,
                                  color: inCart
                                      ? _kTextPrimary
                                      : Colors.white,
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  inCart
                                      ? l10n.matajirInCart
                                      : l10n.matajirAddToCart,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: inCart
                                        ? _kTextPrimary
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

// ── Store Product List Tile ───────────────────────────────────────────────────

class _StoreProductListTile extends StatelessWidget {
  final ProductModel product;
  const _StoreProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.push('/matajir/product/${product.id}', extra: product),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 80.w,
                height: 80.w,
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) =>
                            Container(color: AppTheme.shimmerBase),
                      )
                    : Container(color: AppTheme.shimmerBase),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: _kGreen, size: 10.sp),
                      SizedBox(width: 3.w),
                      Text(
                        'مضمون ✓',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          color: _kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.name,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    IqdFormatter.format(product.price),
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<MatajirCartCubit, CartState>(
              builder: (ctx, cartState) {
                final inCart = cartState.isInCart(product.id);
                return GestureDetector(
                  onTap: () =>
                      ctx.read<MatajirCartCubit>().addToCart(product),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: inCart ? _kBorder : _kPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      inCart
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      size: 18.sp,
                      color: inCart ? _kTextPrimary : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cart Bar ──────────────────────────────────────────────────────────────────

class _CartBar extends StatelessWidget {
  final int count;
  final double total;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _CartBar({
    required this.count,
    required this.total,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _kPrimary,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.matajirProductCount(count),
                    style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.75)),
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
              const Spacer(),
              Row(
                children: [
                  Text(
                    l10n.matajirCompleteOrder,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 13.sp, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
