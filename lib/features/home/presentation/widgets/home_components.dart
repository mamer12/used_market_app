import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/portal_models.dart';

// ── Shared Home Section Wrapper (T014) ───────────────────────────────────────

/// A reusable wrapper for home feed sections that provides consistent padding,
/// an optional title, an optional trailing "See All" link, and RTL support.
class HomeSection extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HomeSection({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null || trailing != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ?trailing,
                ],
              ),
            ),
          if (title != null || trailing != null) SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

// ── Omnibox (T015) ────────────────────────────────────────────────────────────

/// The global search bar "What are you looking for today?".
class OmniboxWidget extends StatelessWidget {
  final String hintText;
  final VoidCallback onTap;

  const OmniboxWidget({super.key, required this.hintText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.3)),
          // Subtle shadow to make it pop over the scrolled background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.inactive, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hintText,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.inactive,
                ),
              ),
            ),
            // The Super App "Scanner" icon (often requested in modern e-comm)
            Icon(
              Icons.center_focus_weak_rounded,
              color: AppTheme.inactive,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Announcements Carousel (T016) ─────────────────────────────────────────────

/// Autoplaying carousel for promotional banners. Built on PageView.
class AnnouncementsCarousel extends StatefulWidget {
  final List<Announcement> items;
  final void Function(Announcement) onTap;

  const AnnouncementsCarousel({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  State<AnnouncementsCarousel> createState() => _AnnouncementsCarouselState();
}

class _AnnouncementsCarouselState extends State<AnnouncementsCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start with a large offset so we can loop infinitely if desired,
    // though for simple MVP we just do bounded.
    _pageController = PageController(
      viewportFraction: 1.0,
    ); // Exactly edge-to-edge as per Stitch
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                  } else {
                    // Initial build state before dimensions are bound
                    value = _currentIndex == index ? 1.0 : 0.85;
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 160.h,
                      width: double.infinity,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () => widget.onTap(item),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: item.colorHex != null
                          ? Color(item.colorHex!)
                          : AppTheme.surface,
                    ),
                    // Optional: You can overlay the `title` from the Announcement here
                    // if it's meant to be text-over-image, but usually banners have baked text.
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 6.h,
              width: _currentIndex == i ? 20.w : 6.w,
              decoration: BoxDecoration(
                color: _currentIndex == i
                    ? AppTheme.primary
                    : AppTheme.inactive.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bento Grid (T017) ─────────────────────────────────────────────────────────

class BentoGrid extends StatelessWidget {
  final Map<String, String> labels; // e.g. {'mazad': '...', 'matajir': '...'}
  final Map<String, String> taglines; // e.g. {'mazad': 'Live Deals', ...}
  final void Function(String id) onTileTap;

  const BentoGrid({
    super.key,
    required this.labels,
    required this.taglines,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  title: labels['mazad'] ?? 'Mazad',
                  tagline: taglines['mazad'] ?? '',
                  icon: Icons.gavel_rounded,
                  color: AppTheme.mazadRed,
                  isLarge: true,
                  onTap: () => onTileTap('mazad'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoTile(
                  title: labels['matajir'] ?? 'Matajir',
                  tagline: taglines['matajir'] ?? '',
                  icon: Icons.storefront_rounded,
                  color: AppTheme.matajirBlue,
                  isLarge: true,
                  onTap: () => onTileTap('matajir'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  title: labels['mustamal'] ?? 'Mustamal',
                  tagline: taglines['mustamal'] ?? '',
                  icon: Icons.change_circle_outlined,
                  color: AppTheme.mustamalOrange,
                  isLarge: false,
                  onTap: () => onTileTap('mustamal'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoTile(
                  title: labels['balla'] ?? 'Balla',
                  tagline: taglines['balla'] ?? '',
                  icon: Icons.inventory_2_outlined,
                  color: AppTheme.ballaPurple,
                  isLarge: false,
                  onTap: () => onTileTap('balla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final String title;
  final String tagline;
  final IconData icon;
  final Color color;
  final bool isLarge;
  final VoidCallback onTap;

  const _BentoTile({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.isLarge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isLarge ? 120.h : 100.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: isLarge ? 28.sp : 24.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  tagline,
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
