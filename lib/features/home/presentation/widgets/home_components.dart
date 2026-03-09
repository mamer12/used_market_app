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
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
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
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppTheme.textTertiary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                hintText,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: AppTheme.textTertiary,
                ),
              ),
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
    _pageController = PageController(viewportFraction: 0.85);
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
          height: 176.h,
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
                    value = _currentIndex == index ? 1.0 : 0.85;
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 176.h,
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
                      color: item.colorHex != null
                          ? Color(item.colorHex!)
                          : AppTheme.primary,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.4,
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.cairo(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                item.actionUrl ??
                                    'Special offers waiting for you',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16.h,
                          left: 16.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Text(
                              'LIVE NOW',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
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
  final Map<String, String> labels;
  final Map<String, String> taglines;
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _BentoTile(
                  title: labels['mazad'] ?? 'Mazad',
                  tagline: 'Live Bidding',
                  icon: Icons.gavel_rounded,
                  color: AppTheme.mazadGreen,
                  onTap: () => onTileTap('mazad'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoTile(
                  title: labels['matajir'] ?? 'Matajir',
                  tagline: 'Official Shops',
                  icon: Icons.storefront_rounded,
                  color: AppTheme.matajirBlue,
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
                  tagline: 'Used Market',
                  icon: Icons.change_circle_rounded,
                  color: AppTheme.mustamalOrange,
                  onTap: () => onTileTap('mustamal'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _BentoTile(
                  title: labels['balla'] ?? 'Balla',
                  tagline: 'Bulk Market',
                  icon: Icons.inventory_2_rounded,
                  color: AppTheme.ballaPurple,
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
  final VoidCallback onTap;

  const _BentoTile({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              tagline,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
