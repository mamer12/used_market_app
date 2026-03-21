import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A full-width auto-scrolling promotional carousel with dot indicators.
///
/// Each [PromotedItem] renders an image with a gradient overlay,
/// a badge, title, and price.
class PromotedCarousel extends StatefulWidget {
  final List<PromotedItem> items;
  final Color primaryColor;
  final double height;

  const PromotedCarousel({
    super.key,
    required this.items,
    required this.primaryColor,
    this.height = 200,
  });

  @override
  State<PromotedCarousel> createState() => _PromotedCarouselState();
}

class _PromotedCarouselState extends State<PromotedCarousel> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.items.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _CarouselSlide(
              item: widget.items[i],
              primaryColor: widget.primaryColor,
            ),
          ),
        ),
        if (widget.items.length > 1) ...[
          SizedBox(height: 8.h),
          _DotIndicator(
            count: widget.items.length,
            current: _currentPage,
            activeColor: widget.primaryColor,
          ),
        ],
      ],
    );
  }
}

class _CarouselSlide extends StatelessWidget {
  final PromotedItem item;
  final Color primaryColor;

  const _CarouselSlide({required this.item, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or color
            if (item.imageUrl != null)
              Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _PlaceholderBg(color: primaryColor),
              )
            else
              _PlaceholderBg(color: primaryColor),

            // Gradient overlay (bottom → top)
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Content overlay
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge
                  if (item.badge != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        item.badge!,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // Title
                  if (item.title != null)
                    Text(
                      item.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if (item.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                  // Price
                  if (item.price != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.price!,
                      style: GoogleFonts.cairo(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderBg extends StatelessWidget {
  final Color color;
  const _PlaceholderBg({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.3),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _DotIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 8.w : 6.w,
          height: isActive ? 8.w : 6.w,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// Data model for a single carousel slide.
class PromotedItem {
  final String? imageUrl;
  final String? badge;
  final String? title;
  final String? subtitle;
  final String? price;
  final VoidCallback? onTap;

  const PromotedItem({
    this.imageUrl,
    this.badge,
    this.title,
    this.subtitle,
    this.price,
    this.onTap,
  });
}
