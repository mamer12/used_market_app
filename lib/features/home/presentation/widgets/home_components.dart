import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../data/models/portal_models.dart';

// ── Home Section Wrapper ─────────────────────────────────────────────────────

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
    this.padding = const EdgeInsets.symmetric(vertical: 20),
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
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          if (title != null || trailing != null) SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

// ── Omnibox with Mic + Camera ─────────────────────────────────────────────────

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
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsetsDirectional.only(start: 16.w, end: 8.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                hintText,
                style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.textTertiary),
              ),
            ),
            Icon(Icons.mic_outlined, color: AppTheme.textTertiary, size: 20.sp),
            SizedBox(width: 12.w),
            Container(width: 1, height: 20.h, color: AppTheme.divider),
            SizedBox(width: 12.w),
            Icon(Icons.photo_camera_outlined, color: AppTheme.textTertiary, size: 20.sp),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}

// ── Wallet Card ───────────────────────────────────────────────────────────────

class WalletCard extends StatefulWidget {
  /// Null = loading, -1 = error
  final int? balanceIqd;
  final int lockedEscrowCount;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;

  const WalletCard({
    super.key,
    required this.balanceIqd,
    this.lockedEscrowCount = 0,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onTransfer,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool _hidden = false;

  static const _cardTop     = Color(0xFF0E4D30);
  static const _cardBottom  = Color(0xFF062518);
  static const _accentGreen = Color(0xFF4ADE80);

  String get _balanceText {
    if (widget.balanceIqd == -1) return '-- د.ع';
    return IqdFormatter.format(widget.balanceIqd!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_cardTop, _cardBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _cardBottom.withValues(alpha: 0.55),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // ── Glass sheen ──────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 70.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.13),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // ── Decorative circle — bottom-end (RTL left) ─
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // ── Content ──────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top row: title / eye / escrow badge ─
                Row(
                  children: [
                    // Escrow badge (start = RTL right visual left)
                    if (widget.lockedEscrowCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4.w),
                            Text(
                              '${widget.lockedEscrowCount} أمانة نشطة',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    // "محفظتي" label + eye toggle
                    GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Row(
                        children: [
                          Text(
                            'محفظتي',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              _hidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              key: ValueKey(_hidden),
                              color: Colors.white.withValues(alpha: 0.70),
                              size: 17.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // ── Balance (animated show/hide) ─────────
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: widget.balanceIqd == null
                      ? SkeletonBox(
                          width: 180.w, height: 42.h, borderRadius: 8.r)
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(
                                opacity: anim,
                                child: ScaleTransition(
                                  scale: Tween(begin: 0.88, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: anim,
                                          curve: Curves.easeOut)),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            _hidden ? '•••••• د.ع' : _balanceText,
                            key: ValueKey(_hidden),
                            style: GoogleFonts.cairo(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                ),
                SizedBox(height: 4.h),
                // ── Available sub-label ──────────────────
                if (widget.balanceIqd != null && widget.balanceIqd! > 0)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      _hidden
                          ? 'متاح للسحب: •••••• د.ع'
                          : 'متاح للسحب: ${IqdFormatter.format((widget.balanceIqd! * 0.64).toInt())} د.ع',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: _accentGreen.withValues(alpha: 0.80),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                SizedBox(height: 22.h),
                // ── 3 Circular action buttons ────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CircleAction(
                      icon: Icons.add_rounded,
                      label: 'إيداع',
                      onTap: widget.onDeposit,
                    ),
                    _CircleAction(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'سحب',
                      onTap: widget.onWithdraw,
                    ),
                    _CircleAction(
                      icon: Icons.swap_horiz_rounded,
                      label: 'تحويل',
                      onTap: widget.onTransfer,
                      highlight: true,
                    ),
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

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _CircleAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlight
                  ? Colors.white.withValues(alpha: 0.28)
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: highlight ? 0.40 : 0.22),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Categories Grid (2 × 4) ─────────────────────────────────────────────

class QuickUtilitiesRow extends StatelessWidget {
  final void Function(String id) onTap;

  const QuickUtilitiesRow({super.key, required this.onTap});

  static const _items = [
    _UtilItem('orders', 'طلباتي', Icons.receipt_long_outlined, null),
    _UtilItem('messages', 'رسائلي', Icons.chat_bubble_outline_rounded, null),
    _UtilItem('favorites', 'مفضلتي', Icons.favorite_outline_rounded, Color(0xFFEC4899)),
    _UtilItem('support', 'الدعم', Icons.headset_mic_outlined, null),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 0,
          childAspectRatio: 0.82,
        ),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          final color = item.color ?? AppTheme.primary;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap(item.id);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.18)),
                  ),
                  child: Icon(item.icon, color: color, size: 24.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UtilItem {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;
  const _UtilItem(this.id, this.label, this.icon, this.color);
}

// ── Announcements Carousel — snap horizontal ──────────────────────────────────

class AnnouncementsCarousel extends StatefulWidget {
  final List<Announcement> items;
  final void Function(Announcement) onTap;

  const AnnouncementsCarousel({super.key, required this.items, required this.onTap});

  @override
  State<AnnouncementsCarousel> createState() => _AnnouncementsCarouselState();
}

class _AnnouncementsCarouselState extends State<AnnouncementsCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140.h,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final bg = item.colorHex != null ? Color(item.colorHex!) : AppTheme.textPrimary;
              return GestureDetector(
                onTap: () => widget.onTap(item),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [bg, Color.lerp(bg, Colors.black, 0.25)!],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.35,
                            child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(18.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.badgeText != null)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  item.badgeText!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              item.title,
                              style: GoogleFonts.cairo(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
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
                    : AppTheme.inactive.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── New Bento Grid (HTML v2 layout) ──────────────────────────────────────────

class BentoGrid extends StatelessWidget {
  final Map<String, String> labels;
  final Map<String, String> taglines;
  final void Function(String id) onTileTap;
  /// Live auction count shown on Mazadat tile badge
  final int liveAuctionCount;

  const BentoGrid({
    super.key,
    required this.labels,
    required this.taglines,
    required this.onTileTap,
    this.liveAuctionCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Row 1: Mazadat (dark) | Matajir (light) — equal width
          Row(
            children: [
              Expanded(
                child: _MazadatTile(
                  label: labels['mazad'] ?? 'مزادات',
                  tagline: taglines['mazad'] ?? 'زايد واربح',
                  liveCount: liveAuctionCount,
                  onTap: () => onTileTap('mazad'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _MatajirTile(
                  label: labels['matajir'] ?? 'متاجر',
                  tagline: taglines['matajir'] ?? 'متاجر موثقة',
                  onTap: () => onTileTap('matajir'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Row 2: Balla — full width landscape
          _BallaTile(
            label: labels['balla'] ?? 'بالة وجملة',
            tagline: taglines['balla'] ?? 'البسطية الرقمية',
            onTap: () => onTileTap('balla'),
          ),
          SizedBox(height: 12.h),
          // Row 3: Mustamal — full width landscape
          _MustamalTile(
            label: labels['mustamal'] ?? 'مستعمل',
            tagline: taglines['mustamal'] ?? 'بيع واشتري بأمان',
            onTap: () => onTileTap('mustamal'),
          ),
        ],
      ),
    );
  }
}

/// Mazadat — dark slate card with red glow + live count badge
class _MazadatTile extends StatelessWidget {
  final String label;
  final String tagline;
  final int liveCount;
  final VoidCallback onTap;

  const _MazadatTile({
    required this.label,
    required this.tagline,
    required this.liveCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF0F0F16);
    const red = AppTheme.mazadGreen; // Mazadat neon red
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: dark,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: [
              BoxShadow(
                color: red.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: icon + live badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: red.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.gavel_rounded, color: Colors.white, size: 20.sp),
                  ),
                  if (liveCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: red.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: red.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulseDot(color: red),
                          SizedBox(width: 4.w),
                          Text(
                            '$liveCount مباشر',
                            style: GoogleFonts.cairo(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                tagline,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Matajir — white card, blue accent, verified badge
class _MatajirTile extends StatelessWidget {
  final String label;
  final String tagline;
  final VoidCallback onTap;

  const _MatajirTile({required this.label, required this.tagline, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const blue = AppTheme.matajirBlue;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: AppTheme.cardElevatedDecoration,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: AppTheme.matajirBlueSurface,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: blue, size: 22),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text(
                      '١٢٠+ متجر',
                      style: GoogleFonts.cairo(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  const Icon(Icons.verified_rounded, color: blue, size: 16),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                tagline,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Balla — wide landscape, purple, diamond icon + CTA button
class _BallaTile extends StatelessWidget {
  final String label;
  final String tagline;
  final VoidCallback onTap;

  const _BallaTile({required this.label, required this.tagline, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const purple = AppTheme.ballaPurple;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppTheme.ballaPurpleSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: purple.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A1D96),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'HOT',
                          style: GoogleFonts.cairo(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    tagline,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: purple.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: purple,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      'تصفح العروض',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: purple.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.diamond_outlined, color: purple, size: 32),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mustamal — wide landscape, sand/amber, category pills + recycle icon
class _MustamalTile extends StatelessWidget {
  final String label;
  final String tagline;
  final VoidCallback onTap;

  const _MustamalTile({required this.label, required this.tagline, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const orange = AppTheme.mustamalOrange;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppTheme.mustamalOrangeSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: orange.withValues(alpha: 0.2)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7C2D12),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    tagline,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: orange.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    children: ['سيارات', 'عقارات', 'أجهزة'].map((cat) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: orange.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.cairo(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7C2D12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Icon(Icons.recycling_rounded, color: orange.withValues(alpha: 0.7), size: 52.sp),
          ],
        ),
      ),
    );
  }
}

// ── Pulse Dot ──────────────────────────────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6.w,
        height: 6.w,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
