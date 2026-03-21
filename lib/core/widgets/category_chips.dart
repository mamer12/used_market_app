import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A horizontally scrolling row of category filter chips.
///
/// The first chip is always "الكل" (All). The selected chip
/// shows the [primaryColor] background with white text; others
/// show a white/surface background with a divider border.
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color primaryColor;
  final Color backgroundColor;
  final bool darkMode;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    required this.primaryColor,
    this.backgroundColor = Colors.white,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = ['الكل', ...categories];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: chips.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final isSelected = i == selectedIndex;
          return _Chip(
            label: chips[i],
            isSelected: isSelected,
            primaryColor: primaryColor,
            backgroundColor: backgroundColor,
            darkMode: darkMode,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(i);
            },
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final Color backgroundColor;
  final bool darkMode;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.backgroundColor,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedBg = darkMode ? const Color(0xFF1E1E2A) : backgroundColor;
    final unselectedBorder =
        darkMode ? Colors.white12 : const Color(0xFFEDE6DC);
    final unselectedText =
        darkMode ? Colors.white60 : const Color(0xFF6B5E52);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : unselectedBg,
          borderRadius: BorderRadius.circular(999.r),
          border: isSelected
              ? null
              : Border.all(color: unselectedBorder, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : unselectedText,
            ),
          ),
        ),
      ),
    );
  }
}
