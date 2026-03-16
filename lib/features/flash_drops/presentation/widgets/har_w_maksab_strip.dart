import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/flash_drop_cubit.dart';
import 'flash_drop_card.dart';

// ── Public widget with its own BlocProvider ───────────────────────────────────

class HarWaMaksabStrip extends StatelessWidget {
  const HarWaMaksabStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FlashDropCubit>(
      create: (_) => getIt<FlashDropCubit>()
        ..fetchActive()
        ..startPolling(),
      child: const _HarWaMaksabStripView(),
    );
  }
}

// ── Inner view ────────────────────────────────────────────────────────────────

class _HarWaMaksabStripView extends StatelessWidget {
  const _HarWaMaksabStripView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlashDropCubit, FlashDropState>(
      builder: (context, state) {
        if (state is FlashDropLoading) {
          return _buildShimmer(context);
        }

        if (state is FlashDropsLoaded) {
          if (state.drops.isEmpty) return const SizedBox.shrink();

          return _buildStrip(context, state);
        }

        // FlashDropError or initial — show nothing
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStrip(BuildContext context, FlashDropsLoaded state) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حار ومكسب',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'كل العروض',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal card list
          SizedBox(
            height: 280.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: state.drops.length,
              separatorBuilder: (context, i) => SizedBox(width: 12.w),
              itemBuilder: (_, i) => FlashDropCard(drop: state.drops[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                Container(
                  width: 60.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 280.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 2,
              separatorBuilder: (context, i) => SizedBox(width: 12.w),
              itemBuilder: (context, i) => Container(
                width: 180.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
