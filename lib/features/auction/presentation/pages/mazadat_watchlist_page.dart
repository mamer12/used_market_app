import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/auctions_cubit.dart';

/// المراقبة — Auction Watchlist page.
///
/// Shows auctions the user is watching/tracking. Uses Stitch Screen 8
/// design language with green (#13EC6A) accent.
class MazadatWatchlistPage extends StatefulWidget {
  const MazadatWatchlistPage({super.key});

  @override
  State<MazadatWatchlistPage> createState() => _MazadatWatchlistPageState();
}

class _MazadatWatchlistPageState extends State<MazadatWatchlistPage> {
  @override
  void initState() {
    super.initState();
    // Load watched auctions when tab is visited
    context.read<AuctionsCubit>().loadWatchedAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AuctionsCubit, AuctionsState>(
        builder: (context, state) {
          final watchedCount = state.watchedAuctions.length;
          
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App Bar ────────────────────────────────
              const SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: false,
                automaticallyImplyLeading: false, // Shell page handles title, so we can hide this or keep it.
                // Removing title here because MazadatShellPage already has a global appbar if needed,
                // but let's keep it if we want custom actions here. Oh wait, MazadatShellPage has an AppBar that covers all tabs.
                // So we can actually remove the SliverAppBar title and just have actions, or just use SliverToBoxAdapter.
              ),

              // ── Stats Row ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: Icons.visibility_rounded,
                        label: 'مراقَبة',
                        count: '$watchedCount',
                        color: AppTheme.mazadGreen,
                      ),
                      SizedBox(width: 8.w),
                      const _StatChip(
                        icon: Icons.notifications_active_rounded,
                        label: 'تنبيهات',
                        count: '٠',
                        color: Color(0xFF3B82F6), // blue
                      ),
                      SizedBox(width: 8.w),
                      const _StatChip(
                        icon: Icons.timer_rounded,
                        label: 'تنتهي قريباً',
                        count: '٠',
                        color: Color(0xFFF59E0B), // amber
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ────────────────────────────
              if (state.isLoadingWatchlist)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.mazadGreen)),
                )
              else if (state.watchedAuctions.isEmpty)
                SliverFillRemaining(
                  child: _EmptyWatchlist(),
                )
              else
                SliverList.separated(
                  itemCount: state.watchedAuctions.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, index) {
                    final item = state.watchedAuctions[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121A),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          item.title,
                          style: GoogleFonts.cairo(color: Colors.white),
                        ),
                      ),
                    ); // Replace with _MazadatAuctionCard if exported
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Stat Chip ───────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 6.h),
            Text(
              count,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Watchlist ─────────────────────────────────────────────────────────
class _EmptyWatchlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.visibility_off_rounded,
                size: 42.sp,
                color: AppTheme.mazadGreen.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا توجد مراقبات نشطة',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'أضف مزادات إلى قائمة المراقبة\nليصلك تنبيه قبل انتهاء المزاد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white54,
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to the main Mazadat auctions list
                context.go('/mazadat');
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 28.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.mazadGreen,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mazadGreen.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded,
                        color: Colors.white, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'تصفح المزادات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

