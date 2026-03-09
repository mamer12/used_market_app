import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Skeleton Loading Primitives & Composites
//
// Uses the existing "Iraqi Bazaar Modernism" shimmer colours
// (AppTheme.shimmerBase / shimmerHighlight) and flutter_animate for the
// sliding highlight effect.
// ═══════════════════════════════════════════════════════════════════════════════

/// A single rounded rectangle that shimmers.  The fundamental building block.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppTheme.shimmerHighlight.withValues(alpha: 0.5),
        );
  }
}

/// A circular skeleton placeholder (e.g., avatars).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.shimmerBase,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: AppTheme.shimmerHighlight.withValues(alpha: 0.5),
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page-specific skeleton composites
// ─────────────────────────────────────────────────────────────────────────────

/// Home page skeleton – app bar placeholder, bento grid, carousels.
class HomePageSkeleton extends StatelessWidget {
  const HomePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // Fake app bar area
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 80.w, height: 28.h),
                SkeletonBox(width: 140.w, height: 32.h, borderRadius: 20.r),
              ],
            ),
          ),
        ),
        // Omnibox placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SkeletonBox(width: double.infinity, height: 48.h, borderRadius: 16.r),
          ),
        ),
        // Carousel banner placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SkeletonBox(width: double.infinity, height: 160.h, borderRadius: 20.r),
          ),
        ),
        // Bento grid (4 tiles)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 100.w, height: 18.h),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 110.h)),
                    SizedBox(width: 12.w),
                    Expanded(child: SkeletonBox(height: 110.h)),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 110.h)),
                    SizedBox(width: 12.w),
                    Expanded(child: SkeletonBox(height: 110.h)),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Product carousel placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 120.w, height: 18.h),
                    SkeletonBox(width: 60.w, height: 14.h),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 180.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, _) => SizedBox(width: 12.w),
                    itemBuilder: (_, _) => SkeletonBox(
                      width: 140.w,
                      height: 180.h,
                      borderRadius: 16.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shops page skeleton – vertical list of shop card placeholders.
class ShopsPageSkeleton extends StatelessWidget {
  const ShopsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 100.h),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => _ShopCardSkeleton(),
    );
  }
}

class _ShopCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SkeletonCircle(size: 52.w),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120.w, height: 16.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 200.w, height: 12.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 80.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Product grid skeleton – 2‑column grid used by shop products, mustamal.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.65,
      ),
      itemCount: itemCount,
      itemBuilder: (_, _) => _ProductCardSkeleton(),
    );
  }
}

/// Sliver version of product grid skeleton.
class SliverProductGridSkeleton extends StatelessWidget {
  const SliverProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 100.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, _) => _ProductCardSkeleton(),
          childCount: itemCount,
        ),
      ),
    );
  }
}

class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SkeletonBox(
              width: double.infinity,
              borderRadius: 16.r,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SkeletonBox(width: double.infinity, height: 12.h),
                  SizedBox(height: 4.h),
                  SkeletonBox(width: 80.w, height: 12.h),
                  SizedBox(height: 4.h),
                  SkeletonBox(width: 60.w, height: 14.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search results skeleton – staggered masonry‑style grid.
class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final heights = [180.h, 220.h, 160.h, 200.h, 190.h, 170.h];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
        ),
        itemCount: 6,
        itemBuilder: (_, index) => SkeletonBox(
          height: heights[index % heights.length],
          borderRadius: 16.r,
        ),
      ),
    );
  }
}

/// Notifications / Orders page skeleton – list of order card placeholders.
class OrdersListSkeleton extends StatelessWidget {
  const OrdersListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(16.w),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: 16.h),
        itemBuilder: (_, _) => _OrderCardSkeleton(),
      ),
    );
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(width: 64.w, height: 64.w, borderRadius: 12.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140.w, height: 14.h),
                    SizedBox(height: 8.h),
                    SkeletonBox(width: 100.w, height: 12.h),
                  ],
                ),
              ),
              SkeletonBox(width: 70.w, height: 26.h, borderRadius: 20.r),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 90.w, height: 12.h),
              SkeletonBox(width: 80.w, height: 14.h),
            ],
          ),
        ],
      ),
    );
  }
}

/// Auction cards skeleton – vertical list (mazadat page).
class AuctionListSkeleton extends StatelessWidget {
  const AuctionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: 16.h),
        itemBuilder: (_, _) => _AuctionCardSkeleton(),
      ),
    );
  }
}

class _AuctionCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: double.infinity,
            height: 180.h,
            borderRadius: 20.r,
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 16.h),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 100.w, height: 14.h),
                    SkeletonBox(width: 80.w, height: 14.h),
                  ],
                ),
                SizedBox(height: 10.h),
                SkeletonBox(width: 140.w, height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Balla product list skeleton – vertical cards.
class BallaListSkeleton extends StatelessWidget {
  const BallaListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: 16.h),
        itemBuilder: (_, _) => _BallaCardSkeleton(),
      ),
    );
  }
}

class _BallaCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 90.w, height: 90.w, borderRadius: 12.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 14.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 140.w, height: 12.h),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 80.w, height: 16.h),
                    SkeletonBox(width: 60.w, height: 28.h, borderRadius: 20.r),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Matajir shop catalog skeleton – shop header + horizontal product row.
class MatajirCatalogSkeleton extends StatelessWidget {
  const MatajirCatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 3,
      separatorBuilder: (_, _) => SizedBox(height: 24.h),
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop header
            Row(
              children: [
                SkeletonCircle(size: 40.w),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100.w, height: 14.h),
                    SizedBox(height: 4.h),
                    SkeletonBox(width: 60.w, height: 10.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Horizontal product row
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => SizedBox(width: 12.w),
                itemBuilder: (_, _) => SkeletonBox(
                  width: 130.w,
                  height: 160.h,
                  borderRadius: 14.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal category chips skeleton.
class CategoryChipsSkeleton extends StatelessWidget {
  const CategoryChipsSkeleton({super.key, this.chipCount = 5});

  final int chipCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: chipCount,
      separatorBuilder: (_, _) => SizedBox(width: 8.w),
      itemBuilder: (_, index) => SkeletonBox(
        width: (60 + (index % 3) * 20).w,
        height: 36.h,
        borderRadius: 20.r,
      ),
    );
  }
}

/// Category items skeleton (taller, icon + label style for matajir).
class CategoryItemsSkeleton extends StatelessWidget {
  const CategoryItemsSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(width: 12.w),
      itemBuilder: (_, _) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonCircle(size: 48.w),
          SizedBox(height: 6.h),
          SkeletonBox(width: 50.w, height: 10.h),
        ],
      ),
    );
  }
}
