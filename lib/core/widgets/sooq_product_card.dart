import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A unified product/listing card used across all 4 mini-apps.
///
/// Supports both **grid** (2-col, image top) and **list** (1-col, image right)
/// layouts. Pass [isGridView] = false for the list layout.
///
/// Colors adapt via [primaryColor]. Badge colors use [badgeColor].
class SooqProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String? subtitle;
  final String? imageUrl;
  final String? badge;
  final Color? badgeColor;
  final Color primaryColor;
  final bool isGridView;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final Widget? actionWidget;
  final bool darkMode;

  const SooqProductCard({
    super.key,
    required this.title,
    required this.price,
    this.subtitle,
    this.imageUrl,
    this.badge,
    this.badgeColor,
    required this.primaryColor,
    this.isGridView = true,
    this.isFavorited = false,
    this.onTap,
    this.onFavorite,
    this.actionWidget,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView ? _GridCard(card: this) : _ListCard(card: this);
  }
}

// ── Grid variant ────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final SooqProductCard card;
  const _GridCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final surfaceBg =
        card.darkMode ? const Color(0xFF12121A) : Colors.white;
    final borderColor =
        card.darkMode ? Colors.white12 : const Color(0xFFEDE6DC);
    final titleColor =
        card.darkMode ? Colors.white : const Color(0xFF1C1713);
    final subtitleColor =
        card.darkMode ? Colors.white54 : const Color(0xFF6B5E52);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        card.onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            SizedBox(
              height: 140.h,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r)),
                    child: _buildImage(width: double.infinity),
                  ),
                  // Badge top-left
                  if (card.badge != null)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: _BadgePill(
                        label: card.badge!,
                        color: card.badgeColor ?? card.primaryColor,
                      ),
                    ),
                  // Favourite top-right
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _FavButton(
                      isFavorited: card.isFavorited,
                      onTap: card.onFavorite,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    card.price,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: card.primaryColor,
                    ),
                  ),
                  if (card.subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      card.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                  if (card.actionWidget != null) ...[
                    SizedBox(height: 8.h),
                    card.actionWidget!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage({double? width}) {
    if (card.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: card.imageUrl!,
        width: width,
        height: 140.h,
        fit: BoxFit.cover,
        placeholder: (_, _) => _ImagePlaceholder(color: card.primaryColor),
        errorWidget: (_, _, _) => _ImagePlaceholder(color: card.primaryColor),
      );
    }
    return _ImagePlaceholder(color: card.primaryColor);
  }
}

// ── List variant ────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final SooqProductCard card;
  const _ListCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final surfaceBg =
        card.darkMode ? const Color(0xFF12121A) : Colors.white;
    final borderColor =
        card.darkMode ? Colors.white12 : const Color(0xFFEDE6DC);
    final titleColor =
        card.darkMode ? Colors.white : const Color(0xFF1C1713);
    final subtitleColor =
        card.darkMode ? Colors.white54 : const Color(0xFF6B5E52);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        card.onTap?.call();
      },
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Text body (left side in RTL)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                    start: 12.w, top: 12.h, bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (card.badge != null)
                      _BadgePill(
                        label: card.badge!,
                        color: card.badgeColor ?? card.primaryColor,
                      ),
                    if (card.badge != null) SizedBox(height: 4.h),
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      card.price,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: card.primaryColor,
                      ),
                    ),
                    if (card.subtitle != null)
                      Text(
                        card.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: subtitleColor,
                        ),
                      ),
                    if (card.actionWidget != null) ...[
                      SizedBox(height: 6.h),
                      card.actionWidget!,
                    ],
                  ],
                ),
              ),
            ),
            // Image (right side in RTL)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: card.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: card.imageUrl!,
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          _ImagePlaceholder(color: card.primaryColor, size: 100),
                      errorWidget: (_, _, _) =>
                          _ImagePlaceholder(color: card.primaryColor, size: 100),
                    )
                  : _ImagePlaceholder(color: card.primaryColor, size: 100),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  final bool isFavorited;
  final VoidCallback? onTap;
  const _FavButton({required this.isFavorited, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 16.sp,
          color: isFavorited ? Colors.red : Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Color color;
  final double size;
  const _ImagePlaceholder({required this.color, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size == 140 ? double.infinity : size.w,
      height: size.h,
      color: color.withValues(alpha: 0.12),
      child: Icon(
        Icons.image_outlined,
        color: color.withValues(alpha: 0.4),
        size: 32.sp,
      ),
    );
  }
}
