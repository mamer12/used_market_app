import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import 'package:http/http.dart' as http;
import '../../../../core/storage/token_storage.dart';
import '../../data/models/shop_models.dart';
import '../bloc/shops_cubit.dart';

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

  static const _filterLabels = [
    '\u0627\u0644\u0643\u0644',
    '\u0647\u0648\u0627\u062a\u0641',
    '\u0644\u0627\u0628\u062a\u0648\u0628',
    '\u0625\u0643\u0633\u0633\u0648\u0627\u0631',
    '\u062a\u0644\u0641\u0632\u064a\u0648\u0646\u0627\u062a',
  ];

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
        backgroundColor: const Color(0xFFF6F6F8),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            BlocBuilder<ShopProductsCubit, ShopProductsState>(
              builder: (context, state) {
                return _StoreHeaderSliver(
                  shop: state.shop,
                  fallbackName: widget.shopName,
                );
              },
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterChipsDelegate(
                selectedIndex: _selectedCategoryIndex,
                labels: _filterLabels,
                onSelected: (i) => setState(() => _selectedCategoryIndex = i),
              ),
            ),
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
                return _buildProductsGrid(context, state, l10n);
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

  Widget _buildProductsGrid(
    BuildContext context,
    ShopProductsState state,
    AppLocalizations l10n,
  ) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.matajirBlue),
                ),
              );
            }
            return _StoreProductCard(product: state.products[index]);
          },
          childCount: state.products.length + (state.isLoading ? 1 : 0),
        ),
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
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined,
                size: 32.sp, color: AppTheme.inactive),
          ),
          SizedBox(height: 14.h),
          Text(
            l10n.matajirShopEmpty,
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.matajirShopEmptySubtitle,
            style: GoogleFonts.cairo(
                fontSize: 13.sp, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context, String message, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppTheme.error),
          SizedBox(height: 12.h),
          Text(message,
              style: GoogleFonts.cairo(
                  fontSize: 14.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _cubit.loadCatalog(widget.shopSlug, refresh: true),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.matajirBlue,
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

// ── Store Header Sliver ────────────────────────────────────────────────────

class _StoreHeaderSliver extends StatefulWidget {
  final ShopModel? shop;
  final String fallbackName;

  const _StoreHeaderSliver({required this.shop, required this.fallbackName});

  @override
  State<_StoreHeaderSliver> createState() => _StoreHeaderSliverState();
}

class _StoreHeaderSliverState extends State<_StoreHeaderSliver> {
  bool _isFollowing = false;
  bool _followLoading = false;

  ShopModel? get shop => widget.shop;
  String get fallbackName => widget.fallbackName;

  Future<void> _toggleFollow() async {
    if (_followLoading || shop == null) return;
    setState(() => _followLoading = true);
    try {
      final token = await getIt<TokenStorage>().getToken();
      final headers = {'Authorization': 'Bearer ${token ?? ''}'};
      final url = Uri.parse('https://api.madhmoon.iq/api/v1/shops/${shop!.id}/follow');
      final res = _isFollowing
          ? await http.delete(url, headers: headers)
          : await http.post(url, headers: headers);
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        if (mounted) setState(() => _isFollowing = !_isFollowing);
      }
    } catch (_) {}
    if (mounted) setState(() => _followLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = shop?.name ?? fallbackName;
    final l10n = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Cover image
              SizedBox(
                height: 130.h,
                width: double.infinity,
                child: shop?.storefrontUrl != null &&
                        shop!.storefrontUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: shop!.storefrontUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, url) =>
                            Container(color: AppTheme.matajirBlueSurface),
                        errorWidget: (_, url, err) =>
                            Container(color: AppTheme.matajirBlueSurface),
                      )
                    : Container(
                        color: AppTheme.matajirBlueSurface,
                        child: Center(
                          child: Icon(Icons.storefront_rounded,
                              size: 48.sp,
                              color: AppTheme.matajirBlue
                                  .withValues(alpha: 0.3)),
                        ),
                      ),
              ),
              // White card below cover
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    if (shop?.verificationStatus == 'verified')
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: AppTheme.success, size: 13.sp),
                            SizedBox(width: 4.w),
                            Text(
                              l10n.matajirVerifiedFull,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10.h),
                    // Rating + sales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '4.8',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.divider,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          l10n.matajirSalesCountPlaceholder,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Follow button
                    SizedBox(
                      height: 36.h,
                      child: ElevatedButton.icon(
                        onPressed: _followLoading ? null : _toggleFollow,
                        icon: Icon(
                          _isFollowing ? Icons.notifications_active : Icons.add_alert_outlined,
                          size: 16.sp,
                        ),
                        label: Text(
                          _isFollowing ? 'متابَع ✓' : 'متابعة',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing
                              ? Colors.grey.shade200
                              : AppTheme.matajirBlue,
                          foregroundColor: _isFollowing
                              ? Colors.black87
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Back button
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
                ),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 18.sp, color: AppTheme.textPrimary),
              ),
            ),
          ),
          // Overlapping logo circle
          Positioned(
            bottom: 68.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: shop?.imageUrl != null && shop!.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: shop!.imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          (shop?.name ?? fallbackName).isNotEmpty
                              ? (shop?.name ?? fallbackName)[0].toUpperCase()
                              : 'S',
                          style: GoogleFonts.cairo(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.matajirBlue,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pinned Filter Chips Delegate ───────────────────────────────────────────

class _FilterChipsDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _FilterChipsDelegate({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: labels.length,
        separatorBuilder: (_, i2) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final selected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: selected ? AppTheme.matajirBlue : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color:
                      selected ? AppTheme.matajirBlue : AppTheme.divider,
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
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterChipsDelegate old) =>
      old.selectedIndex != selectedIndex;
}

// ── Store Product Card ─────────────────────────────────────────────────────

class _StoreProductCard extends StatelessWidget {
  final ProductModel product;
  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () =>
          context.push('/matajir/product/${product.id}', extra: product),
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
                  product.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          fit: BoxFit.cover,
                          placeholder: (_, url) =>
                              Container(color: AppTheme.shimmerBase),
                        )
                      : Container(color: AppTheme.shimmerBase),
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
            // Info
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      product.name,
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
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                        ),
                        Icon(Icons.lock_rounded,
                            color: AppTheme.success, size: 15.sp),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    BlocBuilder<MatajirCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        final inCart = cartState.isInCart(product.id);
                        return GestureDetector(
                          onTap: () => ctx
                              .read<MatajirCartCubit>()
                              .addToCart(product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: inCart
                                  ? AppTheme.divider
                                  : AppTheme.matajirBlue,
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

// ── Cart Bar ───────────────────────────────────────────────────────────────

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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.textPrimary,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
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
                        fontSize: 11.sp, color: Colors.white60),
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
                      color: AppTheme.matajirBlue,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 13.sp, color: AppTheme.matajirBlue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
