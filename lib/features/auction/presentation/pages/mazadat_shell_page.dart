import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/center_fab_bottom_nav.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import 'active_bids_page.dart';
import 'mazadat_account_page.dart';
import 'mazadat_page.dart';
import 'mazadat_watchlist_page.dart';

/// Mazadat Mini-App Shell — 5-slot bottom nav with center FAB:
///   0 = الرئيسية  (MazadatPage — marketplace home)
///   1 = مزايداتي  (ActiveBidsPage — bid history)
///   [FAB] = مزاد جديد (create auction)
///   3 = المراقبة  (MazadatWatchlistPage — watchlist)
///   4 = حسابي    (MazadatAccountPage — profile)
class MazadatShellPage extends StatefulWidget {
  const MazadatShellPage({super.key});

  @override
  State<MazadatShellPage> createState() => _MazadatShellPageState();
}

class _MazadatShellPageState extends State<MazadatShellPage> {
  /// Nav indices: 0,1 → left slots; 3,4 → right slots. FAB at index 2 (center).
  int _selectedIndex = 0;

  void switchToTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  /// Pages mapped by logical slot indices 0,1,3,4 (FAB=2 has no page).
  late final Map<int, Widget> _pageMap = {
    0: const MazadatPage(embeddedInShell: true),
    1: const ActiveBidsPage(),
    3: const MazadatWatchlistPage(),
    4: const MazadatAccountPage(),
  };

  void _onNavTap(int index) {
    if (index == 2) return; // FAB handled separately
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentPage =
        _pageMap[_selectedIndex] ?? _pageMap[0]!;

    return Theme(
      data: _mazadatDarkTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: _buildAppBar(l10n),
        body: currentPage,
        bottomNavigationBar: CenterFabBottomNav(
          items: const [
            NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
            NavItem(icon: Icons.history_rounded, label: 'مزايداتي'),
            NavItem(icon: Icons.visibility_rounded, label: 'المراقبة'),
            NavItem(icon: Icons.person_rounded, label: 'حسابي'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          fabIcon: Icons.gavel_rounded,
          fabColor: const Color(0xFFFF3D5A),
          fabLabel: 'مزاد جديد',
          onFabTap: () => context.push('/mazadat/create'),
          darkMode: true,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: const Color(0xFF12121A),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
        onPressed: () => context.go('/'),
        tooltip: 'الرئيسية',
      ),
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
                    (walletState).balanceIqd.toDouble())
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


