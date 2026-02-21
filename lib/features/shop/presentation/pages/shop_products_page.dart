import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ShopProductsCubit>()
      ..loadCatalog(widget.shopSlug);
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
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            BlocBuilder<ShopProductsCubit, ShopProductsState>(
              builder: (context, state) {
                if (state.isLoading && state.products.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }

                if (state.error != null && state.products.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildError(state.error!),
                  );
                }

                if (state.products.isEmpty) {
                  return SliverFillRemaining(child: _buildEmpty());
                }

                return _buildProductsGrid(state);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── SliverAppBar with shop info ──────────────────────────
  Widget _buildSliverAppBar() {
    return BlocBuilder<ShopProductsCubit, ShopProductsState>(
      builder: (context, state) {
        final shop = state.shop;
        return SliverAppBar(
          expandedHeight: 160.h,
          pinned: true,
          backgroundColor: AppTheme.background,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildShopBanner(shop),
          ),
        );
      },
    );
  }

  Widget _buildShopBanner(ShopModel? shop) {
    final name = shop?.name ?? widget.shopName;
    return Container(
      color: AppTheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 16.h),
            child: Row(
              children: [
                // Shop avatar
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                      style: GoogleFonts.cairo(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shop?.description != null &&
                          shop!.description!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          shop.description!,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '@${shop?.slug ?? widget.shopSlug}',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom border
          Container(
            height: 1,
            color: AppTheme.inactive.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  // ── Products Grid ────────────────────────────────────────
  Widget _buildProductsGrid(ShopProductsState state) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14.h,
          crossAxisSpacing: 14.w,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.products.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              );
            }
            return _buildProductCard(state.products[index]);
          },
          childCount:
              state.products.length + (state.isLoading ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final priceText =
        '${product.price.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} IQD';

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to product detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(14.r),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),
                  // Favourite
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  // Stock badge
                  if (product.inStock <= 3 && product.inStock > 0)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Only ${product.inStock} left',
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!product.isActive)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.inactive,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Sold Out',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
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
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            priceText,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_outlined,
                            size: 15.sp,
                            color: AppTheme.textPrimary,
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

  Widget _placeholderImage() {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Icon(Icons.image_outlined, size: 36.sp, color: AppTheme.inactive),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 36.sp,
              color: AppTheme.inactive,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No products yet',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'This shop has not listed any products',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppTheme.error),
          SizedBox(height: 12.h),
          Text(message, style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _cubit.loadCatalog(widget.shopSlug, refresh: true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
