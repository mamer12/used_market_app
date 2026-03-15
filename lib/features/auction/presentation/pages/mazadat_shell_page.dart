import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../data/models/auction_models.dart';
import '../bloc/auctions_cubit.dart';
import 'active_bids_page.dart';
import 'mazadat_account_page.dart';
import 'mazadat_watchlist_page.dart';

/// Mazadat Mini-App Shell — owns a 4-tab bottom nav:
///   0 = المزادات  (AuctionsContent — the marketplace home)
///   1 = مزايداتي  (ActiveBidsPage — bid history)
///   2 = المراقبة  (MazadatWatchlistPage — watchlist)
///   3 = حسابي    (MazadatAccountPage — profile)
///
/// The [AuctionsCubit] is scoped at the router [ShellRoute] level
/// (see app_router.dart), so it is accessible from all four tabs.
/// [WalletCubit] is provided at the global level in app.dart.
class MazadatShellPage extends StatefulWidget {
  const MazadatShellPage({super.key});

  @override
  State<MazadatShellPage> createState() => _MazadatShellPageState();
}

class _MazadatShellPageState extends State<MazadatShellPage> {
  int _selectedIndex = 0;

  /// Expose tab switcher so children (like watchlist CTA) can switch tabs.
  void switchToTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  late final List<Widget> _pages = [
    const _AuctionsTab(),
    const ActiveBidsPage(),
    const MazadatWatchlistPage(),
    const MazadatAccountPage(),
  ];

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: _mazadatDarkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: _buildAppBar(l10n),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: _MazadatBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          l10n: l10n,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: const Color(0xFF12121A),
      elevation: 0,
      centerTitle: false,
      title: Text(
        l10n.mazadatNavAuctions,
        style: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      actions: [
        // Wallet balance chip — reads global WalletCubit
        BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            final balanceText = walletState is WalletLoaded
                ? IqdFormatter.format(
                    (walletState as WalletLoaded).balanceIqd.toDouble())
                : '---';
            return Container(
              margin: EdgeInsetsDirectional.only(end: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppTheme.mazadGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(
                  color: AppTheme.mazadGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: AppTheme.mazadGreen, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    balanceText,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Mazadat Dark Theme ────────────────────────────────────────────────────────

final _mazadatDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0F),
  primaryColor: AppTheme.mazadGreen, // neon red-pink
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF3D5A),
    secondary: Color(0xFF00F5FF),
    surface: Color(0xFF12121A),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF12121A),
    surfaceTintColor: Colors.transparent,
  ),
  fontFamily: GoogleFonts.cairo().fontFamily,
);

// ── Auctions Tab (reuses AuctionsCubit from ShellRoute) ──────────────────────

/// Lightweight wrapper that shows the auction marketplace content
/// without creating its own AuctionsCubit — uses the one from context.
class _AuctionsTab extends StatelessWidget {
  const _AuctionsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuctionsCubit, AuctionsState>(
      builder: (context, state) {
        if (state.isLoading && state.auctions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.mazadGreen,
              strokeWidth: 2,
            ),
          );
        }

        if (state.error != null && state.auctions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: AppTheme.mazadGreen, size: 48.sp),
                SizedBox(height: 12.h),
                Text(
                  state.error!,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () =>
                      context.read<AuctionsCubit>().loadAuctions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mazadGreen,
                  ),
                  child: Text('إعادة المحاولة',
                      style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (state.auctions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel_rounded,
                    color: Colors.white24, size: 64.sp),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد مزادات حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.mazadGreen,
          onRefresh: context.read<AuctionsCubit>().loadAuctions,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            itemCount: state.auctions.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (_, i) {
              final auction = state.auctions[i];
              return _MazadatAuctionCard(auction: auction);
            },
          ),
        );
      },
    );
  }
}

// ── Auction Card (dark theme) ────────────────────────────────────────────────

class _MazadatAuctionCard extends StatelessWidget {
  final AuctionModel auction;

  const _MazadatAuctionCard({required this.auction});

  @override
  Widget build(BuildContext context) {
    final price = auction.currentPrice ?? auction.startPrice ?? 0;
    final remaining = auction.endTime?.difference(DateTime.now());
    final timeLabel = remaining != null && !remaining.isNegative
        ? '${remaining.inMinutes}د'
        : 'انتهى';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to live auction page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AuctionsCubit>(),
              child: _AuctionLiveRedirect(auction: auction),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              child: auction.images.isNotEmpty
                  ? Image.network(
                      auction.images.first,
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80.w,
                        height: 80.w,
                        color: Colors.white10,
                        child: Icon(Icons.image, color: Colors.white24,
                            size: 32.sp),
                      ),
                    )
                  : Container(
                      width: 80.w,
                      height: 80.w,
                      color: Colors.white10,
                      child: Icon(Icons.gavel_rounded,
                          color: Colors.white24, size: 32.sp),
                    ),
            ),
            SizedBox(width: 12.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    IqdFormatter.format(price.toDouble()),
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.mazadGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_rounded,
                          color: Colors.white54, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        timeLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder redirect — imports the real AuctionLivePage.
class _AuctionLiveRedirect extends StatelessWidget {
  final AuctionModel auction;
  const _AuctionLiveRedirect({required this.auction});

  @override
  Widget build(BuildContext context) {
    // Redirect using go_router would be cleaner, but this works for
    // the tab-internal navigation without losing the shell.
    return const SizedBox.shrink();
  }
}

// ── Bottom Navigation Bar (dark surface, neon red active) ────────────────────

class _MazadatBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppLocalizations l10n;

  const _MazadatBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12121A),
        border: Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.gavel_rounded,
                label: l10n.mazadatNavAuctions,
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: l10n.mazadatNavMyBids,
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.visibility_rounded,
                label: l10n.mazadatNavWatchlist,
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.mazadatNavAccount,
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const _activeColor = Color(0xFFFF3D5A); // neon red
  static const _inactiveColor = Colors.white38;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _activeColor : _inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? _activeColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
