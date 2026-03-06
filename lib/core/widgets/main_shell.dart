import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/auction/presentation/pages/create_auction_page.dart';
import '../../features/cart/presentation/bloc/cart_cubit.dart';
import '../../features/home/presentation/pages/add_balla_page.dart';
import '../../features/home/presentation/pages/create_mustamal_page.dart';
import '../../features/shop/presentation/pages/add_product_page.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// Main scaffold wrapping all root-level pages behind an "Apple Glass"
/// floating bottom navigation bar.
///
/// Nav bar layout (5 slots):
///   Home  |  Cart  |  [CENTER FAB]  |  Notifications  |  Me
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  /// The go_router shell controlling nested navigation.
  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  /// Converts nav bar position (0-4) to page index (0-3).
  /// Position 2 is the center FAB (no page).
  int? _navToPage(int navPos) {
    if (navPos == 2) return null; // center button = action
    if (navPos < 2) return navPos;
    return navPos - 1; // 3→2, 4→3
  }

  late final AnimationController _fabAnim;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fabScale = Tween<double>(
      begin: 1.0,
      end: 0.86,
    ).animate(CurvedAnimation(parent: _fabAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  void _onNavTap(int navPos) {
    final targetBranch = _navToPage(navPos);
    if (targetBranch == null) {
      HapticFeedback.mediumImpact();
      _fabAnim.forward().then((_) => _fabAnim.reverse());
      _showPostSheet();
      return;
    }

    // go_router handles the active branch state
    HapticFeedback.selectionClick();
    widget.navigationShell.goBranch(
      targetBranch,
      // Support tapping the active tab to pop to root of that branch
      initialLocation: targetBranch == widget.navigationShell.currentIndex,
    );
  }

  void _showPostSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _PostActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (ctx, cartState) {
        final safeBottom = MediaQuery.of(ctx).padding.bottom;
        final l10n = AppLocalizations.of(ctx);
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          // We use a transparent bottom nav bar slot so the page extends fully.
          // The actual glass pill is drawn as a Stack overlay inside the body.
          bottomNavigationBar: SizedBox(height: safeBottom + 90),
          body: Stack(
            children: [
              // ── Pages ───────────────────────────────────────────────────
              widget.navigationShell,

              // ── Apple Liquid Glass floating nav pill ─────────────────
              Positioned(
                left: 20,
                right: 20,
                bottom: safeBottom + 14,
                child: _GlassNavPill(
                  currentIndex: widget.navigationShell.currentIndex,
                  cartState: cartState,
                  l10n: l10n,
                  fabScale: _fabScale,
                  onNavTap: _onNavTap,
                  onFabTapDown: () => _fabAnim.forward(),
                  onFabTapUp: () {
                    _fabAnim.reverse();
                    HapticFeedback.mediumImpact();
                    _showPostSheet();
                  },
                  onFabTapCancel: () => _fabAnim.reverse(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Glass Nav Pill ────────────────────────────────────────────────────────
class _GlassNavPill extends StatelessWidget {
  final int currentIndex;
  final CartState cartState;
  final AppLocalizations l10n;
  final Animation<double> fabScale;
  final void Function(int) onNavTap;
  final VoidCallback onFabTapDown;
  final VoidCallback onFabTapUp;
  final VoidCallback onFabTapCancel;

  const _GlassNavPill({
    required this.currentIndex,
    required this.cartState,
    required this.l10n,
    required this.fabScale,
    required this.onNavTap,
    required this.onFabTapDown,
    required this.onFabTapUp,
    required this.onFabTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    const double pillHeight = 70;
    const double fabSize = 62;
    const double fabRise = 26;

    return SizedBox(
      height: pillHeight + fabRise,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Glow shadow drawn OUTSIDE clip ───────────────────────────
          Container(
            height: pillHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(pillHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 36,
                  spreadRadius: -4,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  blurRadius: 22,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // ── Frosted glass pill ─────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(pillHeight / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                height: pillHeight,
                decoration: BoxDecoration(
                  // White @ 0.90 — visible on BOTH dark and light pages
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(pillHeight / 2),
                  border: Border.all(
                    // Subtle dark border — readable on white pages
                    color: Colors.black.withValues(alpha: 0.08),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      activeIcon: Icons.home_rounded,
                      inactiveIcon: Icons.home_outlined,
                      label: l10n.navHome,
                      isActive: currentIndex == 0,
                      onTap: () => onNavTap(0),
                    ),
                    _NavItem(
                      activeIcon: Icons.chat_bubble_rounded,
                      inactiveIcon: Icons.chat_bubble_outline_rounded,
                      label: l10n.navMessages,
                      isActive: currentIndex == 1,
                      onTap: () => onNavTap(1),
                    ),
                    // Gap for the floating FAB
                    const SizedBox(width: fabSize + 8),
                    _NavItem(
                      activeIcon: Icons.receipt_long_rounded,
                      inactiveIcon: Icons.receipt_long_outlined,
                      label: l10n.navActivity,
                      isActive: currentIndex == 2,
                      badgeCount: cartState.cartCount,
                      onTap: () => onNavTap(3),
                    ),
                    _NavItem(
                      activeIcon: Icons.person_rounded,
                      inactiveIcon: Icons.person_outlined,
                      label: l10n.navProfile,
                      isActive: currentIndex == 3,
                      onTap: () => onNavTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Center FAB (floats above pill) ─────────────────────────
          Positioned(
            bottom: pillHeight / 2 - fabSize / 2 + fabRise / 2,
            child: GestureDetector(
              onTapDown: (_) => onFabTapDown(),
              onTapUp: (_) => onFabTapUp(),
              onTapCancel: onFabTapCancel,
              child: ScaleTransition(
                scale: fabScale,
                child: Container(
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.55),
                        blurRadius: 22,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.6),
                        blurRadius: 0,
                        spreadRadius: 2.5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Item Widget ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.isActive,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = AppTheme.primary; // Yellow — pops on white pill
    const inactiveColor = Color(0xFF9E9E9E); // Medium grey — soft on white

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 62,
        height: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with optional badge
            SizedBox(
              width: 28,
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isActive ? activeIcon : inactiveIcon,
                      key: ValueKey(isActive),
                      size: 24,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.liveBadge,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 3),
            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isActive ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Post Action Sheet ─────────────────────────────────────────────────────
class _PostActionSheet extends StatelessWidget {
  const _PostActionSheet();

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, (safeBottom + 24).h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.inactive.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.postSheetTitle,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.postSheetSub,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),

          // 1. إطلاق مزاد — Start Auction
          _PostOption(
            icon: Icons.gavel,
            title: l10n.postAuction,
            subtitle: l10n.postAuctionSub,
            accentColor: AppTheme.liveBadge,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateAuctionPage()),
              );
            },
          ),
          SizedBox(height: 10.h),

          // 2. بيع شيء مستعمل — Sell Used Item (Mustamal)
          _PostOption(
            icon: Icons.autorenew_rounded,
            title: l10n.postSellUsed,
            subtitle: l10n.postSellUsedSub,
            accentColor: AppTheme.secondary,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateMustamalPage()),
              );
            },
          ),
          SizedBox(height: 10.h),

          // 3. إضافة منتج لمتجري — Add to my Shop
          _PostOption(
            icon: Icons.add_shopping_cart_outlined,
            title: l10n.postAddProduct,
            subtitle: l10n.postAddProductSub,
            accentColor: AppTheme.primary,
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AddProductPage()));
            },
          ),
          SizedBox(height: 10.h),

          // 4. بيع بالة / جملة — Sell Balla/Bulk
          _PostOption(
            icon: Icons.inventory_2_rounded,
            title: l10n.postSellBalla,
            subtitle: l10n.postSellBallaSub,
            accentColor: const Color(0xFF7C4DFF),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AddBallaPage()));
            },
          ),
        ],
      ),
    );
  }
}

class _PostOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _PostOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, size: 24.sp, color: accentColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: AppTheme.inactive,
            ),
          ],
        ),
      ),
    );
  }
}
