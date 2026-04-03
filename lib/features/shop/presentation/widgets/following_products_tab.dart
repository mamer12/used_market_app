import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/shop_models.dart';
import '../../data/repositories/follow_repository.dart';

/// "Following" tab content for Matajir home.
///
/// Shows products from shops the user follows.
/// Fetched from GET /api/v1/shops/following/products.
class FollowingProductsTab extends StatefulWidget {
  const FollowingProductsTab({super.key});

  @override
  State<FollowingProductsTab> createState() => _FollowingProductsTabState();
}

class _FollowingProductsTabState extends State<FollowingProductsTab> {
  late final FollowRepository _repo;
  bool _loading = true;
  List<ProductModel> _products = [];

  static const _matajirBlue = AppTheme.matajirBlue;

  @override
  void initState() {
    super.initState();
    _repo = getIt<FollowRepository>();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await _repo.fetchFollowingProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_loading) {
      return const ProductGridSkeleton(itemCount: 4);
    }

    if (_products.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border_rounded,
                  size: 64.sp, color: _matajirBlue.withValues(alpha: 0.4)),
              SizedBox(height: 16.h),
              Text(
                l10n.followingEmpty,
                style: GoogleFonts.tajawal(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                l10n.followingEmptySub,
                style: GoogleFonts.tajawal(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: _matajirBlue,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.68,
        ),
        itemCount: _products.length,
        itemBuilder: (context, i) => _ProductCard(product: _products[i]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.images.isNotEmpty ? product.images.first : null;

    return GestureDetector(
      onTap: () => context.push(
        '/matajir/product/${product.id}',
        extra: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              flex: 3,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const SkeletonBox(
                        width: double.infinity,
                        borderRadius: 0,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.image_outlined,
                            size: 32.sp, color: AppTheme.inactive),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: 32.sp, color: AppTheme.inactive),
                      ),
                    ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      IqdFormatter.format(product.price),
                      style: GoogleFonts.tajawal(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.matajirBlue,
                      ),
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
