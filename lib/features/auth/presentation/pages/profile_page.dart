import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/presentation/pages/active_bids_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../shop/presentation/pages/order_history_page.dart';
import '../../data/models/auth_models.dart';

/// Me tab — user profile from local auth state + /users/me endpoint.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Router guard ensures only authenticated users reach this page.
            return _buildProfile(context, state);
          },
        ),
      ),
    );
  }

  // ── Authenticated ────────────────────────────────────────
  Widget _buildProfile(BuildContext context, AuthState state) {
    final l10n = AppLocalizations.of(context);
    final displayName = state.displayName ?? 'User';
    final phone = state.phoneNumber ?? '';
    final initials = _getInitials(displayName);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        if (state.user != null)
          SliverToBoxAdapter(
            child: _buildStrikesBanner(context, state.user!, l10n),
          ),
        SliverToBoxAdapter(
          child: _buildAvatar(initials, displayName, phone, l10n),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        SliverToBoxAdapter(
          child: _buildSection(
            context,
            l10n.profileSectionAccount,
            _accountItems(context, l10n),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverToBoxAdapter(
          child: _buildSection(
            context,
            l10n.profileSectionSupport,
            _supportItems(context, l10n),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        SliverToBoxAdapter(child: _buildLogoutButton(context, l10n)),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            l10n.profileTitle,
            style: GoogleFonts.cairo(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrikesBanner(
    BuildContext context,
    UserModel user,
    AppLocalizations l10n,
  ) {
    if (user.isBanned) {
      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.gavel_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                l10n.bannedUserWarning,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (user.strikesCount > 0) {
      return Container(
        margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.orange.shade800,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                l10n.strikesWarning(user.strikesCount),
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAvatar(
    String initials,
    String displayName,
    String phone,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.cairo(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (phone.isNotEmpty)
                    Text(
                      phone,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l10n.profileVerified,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildMenuRow(context, item),
                    if (i < items.length - 1)
                      Padding(
                        padding: EdgeInsets.only(left: 56.w),
                        child: Divider(
                          height: 1,
                          color: AppTheme.inactive.withValues(alpha: 0.15),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: item.onTap != null ? () => item.onTap!(context) : null,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                item.icon,
                size: 18.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.onTap != null && item.trailing == null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: AppTheme.inactive,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: () {
          context.read<AuthBloc>().add(const AuthLogoutRequested());
        },
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 20.sp, color: AppTheme.error),
              SizedBox(width: 8.w),
              Text(
                l10n.profileLogOut,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_MenuItem> _accountItems(BuildContext context, AppLocalizations l10n) {
    final currentLocale = context.read<LocaleCubit>().state;
    final isArabic = currentLocale.languageCode == 'ar';
    return [
      _MenuItem(
        icon: Icons.person_outline,
        label: l10n.profileEditProfile,
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.store_outlined,
        label: l10n.profileMyShop,
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        label: l10n.profileOrderHistory,
        onTap: (_) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const OrderHistoryPage()));
        },
      ),
      _MenuItem(
        icon: Icons.gavel_outlined,
        label: l10n.profileActiveBids,
        onTap: (_) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ActiveBidsPage()));
        },
      ),
      _MenuItem(
        icon: Icons.favorite_outline,
        label: l10n.profileSavedItems,
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.language_outlined,
        label: l10n.profileLanguage,
        onTap: (_) => context.read<LocaleCubit>().toggleLocale(),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            isArabic ? 'العربية' : 'English',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    ];
  }

  List<_MenuItem> _supportItems(BuildContext context, AppLocalizations l10n) {
    return [
      _MenuItem(
        icon: Icons.help_outline,
        label: l10n.profileHelpCenter,
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        label: l10n.profilePrivacyPolicy,
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.info_outline,
        label: l10n.profileAppVersion,
        onTap: null,
        trailing: Text(
          'v1.0.0',
          style: GoogleFonts.cairo(fontSize: 12.sp, color: AppTheme.inactive),
        ),
      ),
    ];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final void Function(BuildContext)? onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
}
