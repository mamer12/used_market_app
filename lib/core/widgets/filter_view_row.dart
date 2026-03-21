import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A 40-px tall row with:
///   - Right: category dropdown chip (label + chevron)
///   - Left:  grid/list toggle buttons
///
/// Used at the top of every mini-app product feed.
class FilterViewRow extends StatelessWidget {
  final String filterLabel;
  final bool isGridView;
  final ValueChanged<bool> onViewChanged;
  final VoidCallback? onFilterTap;
  final Color primaryColor;
  final bool darkMode;

  const FilterViewRow({
    super.key,
    this.filterLabel = 'كل الأقسام',
    required this.isGridView,
    required this.onViewChanged,
    this.onFilterTap,
    required this.primaryColor,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = darkMode ? Colors.white : const Color(0xFF1C1713);
    final inactiveColor =
        darkMode ? Colors.white38 : const Color(0xFFA89585);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Row(
        children: [
          // Grid icon
          _ToggleIcon(
            icon: Icons.grid_view_rounded,
            active: isGridView,
            activeColor: primaryColor,
            inactiveColor: inactiveColor,
            onTap: () {
              HapticFeedback.selectionClick();
              onViewChanged(true);
            },
          ),
          SizedBox(width: 8.w),
          // List icon
          _ToggleIcon(
            icon: Icons.view_list_rounded,
            active: !isGridView,
            activeColor: primaryColor,
            inactiveColor: inactiveColor,
            onTap: () {
              HapticFeedback.selectionClick();
              onViewChanged(false);
            },
          ),
          const Spacer(),
          // Filter dropdown chip
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: darkMode
                    ? const Color(0xFF1E1E2A)
                    : const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: darkMode ? Colors.white12 : const Color(0xFFD8D0C8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.expand_more_rounded,
                    size: 16.sp,
                    color: textColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    filterLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _ToggleIcon({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(
          icon,
          size: 22.sp,
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}
