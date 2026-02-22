import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/bloc/cart_cubit.dart';
import '../../data/models/shop_models.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildProductInfo(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surface,
      expandedHeight: 400.h,
      pinned: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            product.images.isNotEmpty
                ? Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.surface,
                    AppTheme.surface.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppTheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 60.sp,
          color: AppTheme.inactive,
        ),
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.cairo(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              _buildSaveButton(),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '${product.price.toInt()} د.ع', // Simplified formatting for now
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 24.h),

          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          SizedBox(height: 24.h),

          // Status & SKU
          Row(
            children: [
              _buildInfoBadge(
                icon: Icons.inventory_2_outlined,
                label: product.inStock > 0
                    ? '${product.inStock} in stock'
                    : 'Out of stock',
                color: product.inStock > 0
                    ? AppTheme.liveBadge
                    : AppTheme.inactive,
              ),
              SizedBox(width: 12.w),
              if (product.sku != null)
                _buildInfoBadge(
                  icon: Icons.qr_code_2_rounded,
                  label: 'SKU: ${product.sku}',
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
          SizedBox(height: 24.h),

          // Description
          Text(
            'Description',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            product.description ?? 'No description provided.',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isSaved = state.savedItems.any(
          (item) => item.product.id == product.id,
        );
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<CartCubit>().toggleSaved(product);
          },
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSaved
                    ? AppTheme.liveBadge
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              size: 20.sp,
              color: isSaved ? AppTheme.liveBadge : AppTheme.textSecondary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        16.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final inCart = state.cartItems.any(
            (item) => item.product.id == product.id,
          );

          return GestureDetector(
            onTap: () {
              if (inCart) {
                // Ignore or navigate to cart
                Navigator.pop(context); // just an example
                return;
              }
              HapticFeedback.mediumImpact();
              context.read<CartCubit>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added to Cart', style: GoogleFonts.cairo()),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56.h,
              decoration: BoxDecoration(
                color: inCart ? AppTheme.background : AppTheme.primary,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: inCart ? AppTheme.primary : Colors.transparent,
                ),
                boxShadow: inCart
                    ? []
                    : [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      inCart
                          ? Icons.check_rounded
                          : Icons.shopping_cart_outlined,
                      color: inCart ? AppTheme.primary : AppTheme.textPrimary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      inCart ? 'Added to Cart' : 'Add to Cart',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: inCart ? AppTheme.primary : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
