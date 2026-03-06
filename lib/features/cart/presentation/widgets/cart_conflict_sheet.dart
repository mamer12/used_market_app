import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/cart_context.dart';
import '../bloc/cart_cubit.dart'; // import CartConflictData

/// A bottom sheet presented when the user attempts to add an item
/// from a different Mini-App context to a cart that already has items.
///
/// It gives the user a choice between:
/// 1. Keeping their current cart (ignoring the new item).
/// 2. Clearing the cart and adding the new item.
class CartConflictSheet extends StatelessWidget {
  const CartConflictSheet({super.key});

  /// Presents the sheet and handles the cubit resolution based on user choice.
  /// Needs the [BuildContext] containing the active [ScopedCartCubit].
  static Future<void> show(BuildContext context) {
    final cubit = context.read<ScopedCartCubit>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: cubit, // Pass the scoped cubit into the sheet's tree
          child: const CartConflictSheet(),
        );
      },
    ).then((_) {
      // If the sheet is dismissed without a choice (e.g. tap outside),
      // we must still resolve the conflict state or the app remains stuck.
      final state = cubit.state;
      if (state.cartStatus == CartStatus.conflict) {
        cubit.resolveConflictByKeeping();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ScopedCartCubit>().state;
    final conflictData = state.conflictData;

    // If there's no conflict data, nothing to show
    if (conflictData == null) return const SizedBox.shrink();

    // The user tried to add an item belonging to this target context
    final targetContextApi = conflictData.pendingContextApiValue;

    // Determine the theme colors based on the pending item's origin.
    // 'matajir' vs 'balla' etc.
    final Color targetColor = targetContextApi == CartAppContext.balla.apiValue
        ? AppTheme.ballaPurple
        : AppTheme.matajirBlue;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.inactive.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Warning Icon
            Center(
              child: CircleAvatar(
                radius: 32.r,
                backgroundColor: AppTheme.error.withValues(alpha: 0.1),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.error,
                  size: 32.sp,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              l10n.cartConflictTitle,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              l10n.cartConflictMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Action: Keep Current
            OutlinedButton(
              onPressed: () {
                context.read<ScopedCartCubit>().resolveConflictByKeeping();
                Navigator.of(context).pop();
              },
              child: Text(l10n.cartConflictKeep),
            ),
            SizedBox(height: 16.h),

            // Action: Clear and Add New
            ElevatedButton(
              onPressed: () {
                context.read<ScopedCartCubit>().resolveConflictByClear();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: targetColor),
              child: Text(l10n.cartConflictClear),
            ),
          ],
        ),
      ),
    );
  }
}
