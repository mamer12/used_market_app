import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// 5-slot bottom navigation bar with a center FAB (slot 3).
///
/// Layout: [slot0] [slot1] [FAB] [slot3] [slot4]
///
/// The FAB is a 56-px circle that overlaps the top of the nav bar by 28px,
/// creating the "floating center button" effect.
///
/// Usage:
/// ```dart
/// CenterFabBottomNav(
///   items: [...],
///   currentIndex: _index,
///   onTap: _onNavTap,
///   fabIcon: Icons.add,
///   fabColor: AppTheme.matajirBlue,
///   onFabTap: () => context.push('/add-product'),
///   darkMode: false,
/// )
/// ```
class CenterFabBottomNav extends StatelessWidget {
  /// Exactly 4 nav items (slot 0, 1, 3, 4). Slot 2 is the FAB.
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  // FAB config
  final IconData fabIcon;
  final Color fabColor;
  final VoidCallback? onFabTap;
  final String? fabLabel;

  // Theme
  final bool darkMode;
  final Color? surfaceColor;
  final int? badgeIndexInItems; // index in [items] that gets a badge
  final int badgeCount;

  const CenterFabBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.fabIcon,
    required this.fabColor,
    this.onFabTap,
    this.fabLabel,
    this.darkMode = false,
    this.surfaceColor,
    this.badgeIndexInItems,
    this.badgeCount = 0,
  }) : assert(items.length == 4, 'CenterFabBottomNav requires exactly 4 items');

  @override
  Widget build(BuildContext context) {
    final bg = surfaceColor ??
        (darkMode ? const Color(0xFF12121A) : Colors.white);
    final borderColor = darkMode ? Colors.white10 : const Color(0xFFEDE6DC);
    final inactiveColor =
        darkMode ? Colors.white38 : const Color(0xFFA89585);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 5-slot row (slot 2 is invisible spacer)
              Row(
                children: [
                  // Slot 0
                  _NavSlot(
                    item: items[0],
                    isSelected: currentIndex == 0,
                    hasBadge: badgeIndexInItems == 0 && badgeCount > 0,
                    badgeCount: badgeCount,
                    activeColor: fabColor,
                    inactiveColor: inactiveColor,
                    darkMode: darkMode,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(0);
                    },
                  ),
                  // Slot 1
                  _NavSlot(
                    item: items[1],
                    isSelected: currentIndex == 1,
                    hasBadge: badgeIndexInItems == 1 && badgeCount > 0,
                    badgeCount: badgeCount,
                    activeColor: fabColor,
                    inactiveColor: inactiveColor,
                    darkMode: darkMode,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(1);
                    },
                  ),
                  // FAB placeholder (empty space)
                  const Expanded(child: SizedBox()),
                  // Slot 3
                  _NavSlot(
                    item: items[2],
                    isSelected: currentIndex == 3,
                    hasBadge: badgeIndexInItems == 2 && badgeCount > 0,
                    badgeCount: badgeCount,
                    activeColor: fabColor,
                    inactiveColor: inactiveColor,
                    darkMode: darkMode,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(3);
                    },
                  ),
                  // Slot 4
                  _NavSlot(
                    item: items[3],
                    isSelected: currentIndex == 4,
                    hasBadge: badgeIndexInItems == 3 && badgeCount > 0,
                    badgeCount: badgeCount,
                    activeColor: fabColor,
                    inactiveColor: inactiveColor,
                    darkMode: darkMode,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(4);
                    },
                  ),
                ],
              ),

              // Center FAB — overlaps nav bar top by 28px
              Positioned(
                top: -28.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onFabTap?.call();
                        },
                        child: Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                            color: fabColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: fabColor.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            fabIcon,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                      ),
                      if (fabLabel != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          fabLabel!,
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            color: darkMode
                                ? Colors.white54
                                : const Color(0xFF6B5E52),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final bool hasBadge;
  final int badgeCount;
  final Color activeColor;
  final Color inactiveColor;
  final bool darkMode;
  final VoidCallback onTap;

  const _NavSlot({
    required this.item,
    required this.isSelected,
    required this.hasBadge,
    required this.badgeCount,
    required this.activeColor,
    required this.inactiveColor,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 8.h),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(item.icon, color: color, size: 24.sp),
                if (hasBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: darkMode
                              ? const Color(0xFF12121A)
                              : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: GoogleFonts.cairo(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              item.label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data for a single nav slot.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}
