import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../data/models/portal_models.dart';

// ── Curated Carousel (T018) ───────────────────────────────────────────────────

/// A horizontal scrolling list of products (e.g., "Recently Viewed", "Trending").
///
/// Each item is rendered as a clean, styled card showing an image, title, price,
/// and an optional condition/badge. Handled mostly with ProductPreview model.
class CuratedCarousel extends StatelessWidget {
  final List<ProductPreview> products;
  final void Function(ProductPreview) onProductTap;

  const CuratedCarousel({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(
            product: product,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductPreview product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.inactive.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.inactive.withValues(alpha: 0.1),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),

            // Details Area
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          IqdFormatter.format(product.price),
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                        // Add to cart icon or context badge
                        if (product.contextType != null)
                          _ContextBadge(type: product.contextType!),
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
}

class _ContextBadge extends StatelessWidget {
  final String type;

  const _ContextBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(type);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getLabel(type).toUpperCase(),
        style: GoogleFonts.cairo(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  Color _getColor(String type) {
    if (type.contains('matajir')) return AppTheme.matajirBlue;
    if (type.contains('balla')) return AppTheme.ballaPurple;
    if (type.contains('mazad')) return AppTheme.mazadRed;
    return AppTheme.mustamalOrange;
  }

  String _getLabel(String type) {
    if (type.contains('matajir')) return 'MTJR';
    if (type.contains('balla')) return 'BULK';
    if (type.contains('mazad')) return 'BID';
    return 'USED';
  }
}
