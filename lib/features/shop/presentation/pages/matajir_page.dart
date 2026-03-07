import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
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
          backgroundColor: const Color(
            0xFFF6F7F8,
          ), // background-light from HTML
          body: SafeArea(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Contextual App Bar ────────
                SliverAppBar(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  elevation: 0,
                  pinned: true,
                  centerTitle: false,
                  iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  title: Text(
                    'المتاجر الرسمية',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0F172A),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  actions: [
                    BlocBuilder<MatajirCartCubit, CartState>(
                      builder: (ctx, cartState) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: const Color(0xFF0F172A),
                                  size: 24.sp,
                                ),
                              ),
                              onPressed: () => context.push('/matajir/cart'),
                            ),
                            if (cartState.cartCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.matajirBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cartState.cartCount}',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 10.sp,
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
                    SizedBox(width: 8.w),
                  ],
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // slate-100
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF94A3B8), // slate-400
                            size: 22.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'ابحث عن متجر أو منتج...',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF94A3B8),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Categories ──
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      children: [
                        const _CategoryItem(
                          icon: Icons.devices_rounded,
                          label: 'إلكترونيات',
                          isSelected: true,
                        ),
                        SizedBox(width: 12.w),
                        const _CategoryItem(
                          icon: Icons.checkroom_rounded,
                          label: 'أزياء',
                        ),
                        SizedBox(width: 12.w),
                        const _CategoryItem(
                          icon: Icons.kitchen_rounded,
                          label: 'أجهزة',
                        ),
                        SizedBox(width: 12.w),
                        const _CategoryItem(
                          icon: Icons.face_retouching_natural_rounded,
                          label: 'جمال',
                        ),
                        SizedBox(width: 12.w),
                        const _CategoryItem(
                          icon: Icons.toys_rounded,
                          label: 'ألعاب',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Hero Banner ──
                SliverToBoxAdapter(
                  child: Container(
                    height: 180.h,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12.r),
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
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 120.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.r),
                                bottomRight: Radius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24.h,
                          right: 24.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Icon(
                                      Icons.android,
                                      size: 16.sp,
                                    ), // Samsung-ish placeholder
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.matajirBlue,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'متجر رسمي',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'SAMSUNG Official Store',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                'عروض الحجز المسبق لفئة S24 الجديدة!',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.isLoading && state.shopCatalogs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.matajirBlue,
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
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المتاجر الموثوقة',
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'عرض الكل',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.matajirBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            alignment: WrapAlignment.start,
                            children: state.shopCatalogs.take(6).map((cat) {
                              final shop = cat.shop;
                              return SizedBox(
                                width:
                                    (MediaQuery.of(context).size.width - 56.w) /
                                    3, // 3 columns
                                child: _MerchantCard(
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
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                          child: Text(
                            'أحدث المنتجات الرسمية',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
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
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio:
                              0.58, // Adjusted strictly for the button
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

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _CategoryItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? AppTheme.matajirBlue.withValues(alpha: 0.05)
                : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isSelected
                  ? AppTheme.matajirBlue
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? AppTheme.matajirBlue
                  : const Color(0xFF475569),
              size: 28.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppTheme.matajirBlue : const Color(0xFF475569),
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                    placeholder: (context, url) =>
                        Container(color: const Color(0xFFF1F5F9)),
                  )
                else
                  Container(color: const Color(0xFFF1F5F9)),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 18.sp,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
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
                        'Official Store',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.name,
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            IqdFormatter.format(
                              item.price,
                            ).replaceAll(' IQD', ''),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'د.ع',
                            style: GoogleFonts.cairo(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.matajirBlue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      BlocBuilder<MatajirCartCubit, CartState>(
                        builder: (ctx, cartState) {
                          final inCart = cartState.isInCart(item.id);
                          return GestureDetector(
                            onTap: () {
                              ctx.read<MatajirCartCubit>().addToCart(item);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 36.h,
                              decoration: BoxDecoration(
                                color: inCart
                                    ? const Color(0xFFE2E8F0)
                                    : AppTheme.matajirBlue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    inCart
                                        ? Icons.check_rounded
                                        : Icons.add_shopping_cart_rounded,
                                    color: inCart
                                        ? const Color(0xFF0F172A)
                                        : Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    inCart ? 'في السلة' : 'إضافة للسلة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: inCart
                                          ? const Color(0xFF0F172A)
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
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: shop.imageUrl!,
                              width: 52.w,
                              height: 52.w,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            shop.name.isNotEmpty
                                ? shop.name[0].toUpperCase()
                                : 'S',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
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
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppTheme.matajirBlue,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              shop.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
