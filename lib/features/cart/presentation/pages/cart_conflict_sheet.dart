import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/cart_context.dart';

class CartConflictSheet extends StatelessWidget {
  final ScopedCartCubit cubit;

  const CartConflictSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, ScopedCartCubit cubit) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CartConflictSheet(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              color: AppTheme.error,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            l10n.cartConflictTitle,
            style: GoogleFonts.cairo(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),

          // Message
          Text(
            l10n.cartConflictMessage,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),

          // Actions
          Row(
            children: [
              // Keep Existing
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    cubit.resolveConflictByKeeping();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppTheme.inactive),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    l10n.cartConflictKeep,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Clear & Add
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cubit.resolveConflictByClear();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    l10n.cartConflictClear,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
