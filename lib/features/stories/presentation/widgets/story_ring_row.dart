import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/story_model.dart';
import '../bloc/story_cubit.dart';

// ── Ring color by sooq context ────────────────────────────────────────────────

Color _ringColor(String sooqContext) {
  switch (sooqContext) {
    case 'matajir':
      return const Color(0xFF1B4FD8);
    case 'balla':
      return const Color(0xFF7C3AED);
    case 'mustamal':
      return const Color(0xFFEA580C);
    case 'mazadat':
      return const Color(0xFFFF3D5A);
    default:
      return const Color(0xFF1B4FD8);
  }
}

// ── Public widget with its own BlocProvider ───────────────────────────────────

class StoryRingRow extends StatelessWidget {
  const StoryRingRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryCubit>(
      create: (_) => getIt<StoryCubit>()..fetchFeed(),
      child: const _StoryRingRowView(),
    );
  }
}

// ── Inner view ────────────────────────────────────────────────────────────────

class _StoryRingRowView extends StatelessWidget {
  const _StoryRingRowView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryCubit, StoryState>(
      builder: (context, state) {
        if (state is StoryLoading) {
          return _buildShimmer();
        }

        if (state is StoriesLoaded) {
          if (state.groups.isEmpty) return const SizedBox.shrink();

          // Sorted: unwatched groups first (cubit already sorts, but enforce here)
          final sorted = [...state.groups]
            ..sort((a, b) =>
                (b.hasUnwatched ? 1 : 0) - (a.hasUnwatched ? 1 : 0));

          return SizedBox(
            height: 88.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: sorted.length,
              separatorBuilder: (context, i) => SizedBox(width: 12.w),
              itemBuilder: (_, i) => _StoryAvatar(group: sorted[i]),
            ),
          );
        }

        // StoryError or StoryInitial — show nothing on home screen
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      height: 88.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        separatorBuilder: (context, i) => SizedBox(width: 12.w),
        itemBuilder: (context, i) => const _ShimmerAvatar(),
      ),
    );
  }
}

// ── Story avatar item ─────────────────────────────────────────────────────────

class _StoryAvatar extends StatelessWidget {
  final StoryGroupModel group;

  const _StoryAvatar({required this.group});

  @override
  Widget build(BuildContext context) {
    final ringColor = group.hasUnwatched
        ? _ringColor(group.sooqContext)
        : AppTheme.inactive;
    final initial =
        group.shopName.isNotEmpty ? group.shopName[0] : 'م';

    return GestureDetector(
      onTap: () {
        // Navigate to the story viewer page via go_router
        context.push('/stories/view/${group.shopId}');
      },
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ring + avatar
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor,
                  width: 2.5,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _ringColor(group.sooqContext).withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: group.shopLogoUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          group.shopLogoUrl,
                          width: 48.w,
                          height: 48.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            initial,
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: _ringColor(group.sooqContext),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initial,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _ringColor(group.sooqContext),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 4.h),
            // Shop name
            Text(
              group.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _ShimmerAvatar extends StatelessWidget {
  const _ShimmerAvatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 40.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }
}
