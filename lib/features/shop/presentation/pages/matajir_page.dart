import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../../cart/presentation/cubit/matajir_cart_cubit.dart';
import '../../../cart/presentation/pages/cart_conflict_sheet.dart';
import '../../../home/presentation/bloc/home_cubit.dart';
import '../../data/models/shop_models.dart';
import 'shop_products_page.dart';

class MatajirPage extends StatefulWidget {
  const MatajirPage({super.key});

  @override
  State<MatajirPage> createState() => _MatajirPageState();
}

class _MatajirPageState extends State<MatajirPage> {
  late final HomeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HomeCubit>()..loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _cubit)],
      child: BlocListener<MatajirCartCubit, CartState>(
        listenWhen: (prev, curr) =>
            curr.cartStatus == CartStatus.conflict &&
            prev.cartStatus != CartStatus.conflict,
        listener: (context, state) {
          CartConflictSheet.show(context, context.read<MatajirCartCubit>());
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Contextual App Bar — shows Matajir cart icon ────────
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  centerTitle: true,
                  iconTheme: const IconThemeData(color: Colors.black87),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.matajirTitle,
                        style: GoogleFonts.cairo(
                          color: Colors.black87,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.verified,
                        color: AppTheme.matajirBlue,
                        size: 20.sp,
                      ),
                    ],
                  ),
                  // Matajir-specific cart icon in the trailing action
                  actions: [
                    BlocBuilder<MatajirCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.black87,
                              ),
                              onPressed: () => context.push('/matajir/cart'),
                            ),
                            if (cartState.cartCount > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.matajirBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartState.cartCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),

                // ── Hero Banner ──
                SliverToBoxAdapter(
                  child: Container(
                    height: 180.h,
                    margin: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.matajirBlue,
                      borderRadius: BorderRadius.circular(24.r),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&q=80&w=800',
                        ),
                        fit: BoxFit.cover,
                        opacity: 0.8,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 24.h,
                          right: 24.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'SAMSUNG OFFICIAL',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.matajirBlue,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Galaxy S24 Series\nNow Available',
                                textAlign: TextAlign.right,
                                style: GoogleFonts.cairo(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      height: 54.h,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppTheme.inactive.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: AppTheme.inactive,
                            size: 22.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Search official stores...',
                              style: GoogleFonts.cairo(
                                color: AppTheme.inactive,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.tune_rounded,
                            color: AppTheme.matajirBlue,
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.isLoading && state.shopCatalogs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        ),
                      );
                    }

                    if (state.shopCatalogs.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'لا يوجد متاجر حالياً',
                            style: GoogleFonts.cairo(fontSize: 16.sp),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // ── Verified Merchants ──
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Verified Merchants',
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20.sp,
                                color: AppTheme.matajirBlue,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 120.h,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            scrollDirection: Axis.horizontal,
                            itemCount: state.shopCatalogs.length,
                            separatorBuilder: (_, _) => SizedBox(width: 16.w),
                            itemBuilder: (context, index) {
                              final shop = state.shopCatalogs[index].shop;
                              return _MerchantCard(
                                shop: shop,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShopProductsPage(
                                        shopSlug: shop.slug,
                                        shopName: shop.name,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        // Divider
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Divider(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Text(
                            'Featured Products',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ]),
                    );
                  },
                ),

                // Grid Products
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    final List<ProductModel> allProducts = [];
                    for (var cat in state.shopCatalogs) {
                      allProducts.addAll(cat.products);
                    }

                    if (allProducts.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.62,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _MatajirProductCard(item: allProducts[index]);
                        }, childCount: allProducts.length),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatajirProductCard extends StatelessWidget {
  final ProductModel item;

  const _MatajirProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                if (item.images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: item.images.first,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  )
                else
                  Container(
                    color: AppTheme.surface,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppTheme.inactive,
                      size: 40.sp,
                    ),
                  ),
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.matajirBlue,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        IqdFormatter.format(item.price),
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.matajirBlue,
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<MatajirCartCubit, CartState>(
                    builder: (ctx, cartState) {
                      final inCart = cartState.isInCart(item.id);
                      return GestureDetector(
                        onTap: () {
                          ctx.read<MatajirCartCubit>().addToCart(item);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to Matajir Cart',
                                style: GoogleFonts.cairo(),
                              ),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppTheme.matajirBlue,
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 38.h,
                          decoration: BoxDecoration(
                            color: inCart
                                ? AppTheme.surface
                                : AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(12.r),
                            border: inCart
                                ? Border.all(
                                    color: AppTheme.matajirBlue,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                inCart
                                    ? Icons.done_all_rounded
                                    : Icons.add_rounded,
                                color: inCart
                                    ? AppTheme.matajirBlue
                                    : Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                inCart ? 'IN CART' : 'ADD TO CART',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: inCart
                                      ? AppTheme.matajirBlue
                                      : Colors.white,
                                  letterSpacing: 0.5,
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
    );
  }
}

class _MerchantCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const _MerchantCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.matajirBlue.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: shop.imageUrl!,
                            width: 68.w,
                            height: 68.w,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          shop.name.isNotEmpty
                              ? shop.name[0].toUpperCase()
                              : 'S',
                          style: GoogleFonts.cairo(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.matajirBlue,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2.h,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppTheme.matajirBlue,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 80.w,
            child: Text(
              shop.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
