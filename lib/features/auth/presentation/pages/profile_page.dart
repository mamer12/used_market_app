import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../shop/presentation/pages/order_history_page.dart';
import '../../data/models/auth_models.dart';

// -- Page --

/// Me tab — Stitch v2 redesign with Tajawal font and structured menu.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String _localName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return _buildProfile(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, AuthState state) {
    final l10n = AppLocalizations.of(context);
    final displayName =
        _localName.isNotEmpty ? _localName : (state.displayName ?? 'User');
    final phone = state.phoneNumber ?? '';
    final initials = _getInitials(displayName);
    final isSeller = state.user?.role == 'seller';

    return CustomScrollView(
      slivers: [
        // -- Header --
        SliverToBoxAdapter(child: _buildHeader(context, l10n)),

        // -- Strikes banner --
        if (state.user != null)
          SliverToBoxAdapter(
            child: _buildStrikesBanner(context, state.user!, l10n),
          ),

        // -- Avatar card --
        SliverToBoxAdapter(
          child: _buildAvatarCard(
            context,
            initials,
            displayName,
            phone,
            l10n,
            state,
            isSeller,
          ),
        ),

        // -- Stats row --
        // SliverToBoxAdapter(child: _buildStatsRow(context)),

        // -- Wallet chip --
        // SliverToBoxAdapter(child: _buildWalletChip(context, l10n)),

        // -- Orders quick section --
        // SliverToBoxAdapter(child: _buildOrdersQuickSection(context)),

        // -- Edit form --
        if (_isEditing)
          SliverToBoxAdapter(child: _buildEditForm(context, l10n)),

        SliverToBoxAdapter(child: SizedBox(height: 20.h)),

        // -- Menu items --
        SliverToBoxAdapter(
          child: _buildMenuSection(context, l10n, isSeller),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 12.h)),

        // -- Logout --
        SliverToBoxAdapter(child: _buildLogoutButton(context, l10n)),

        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: AppTheme.dinarGold,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            l10n.profileTitle,
            style: GoogleFonts.tajawal(
              fontSize: 24.sp,
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
        margin: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
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
                style: GoogleFonts.tajawal(
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
        margin: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.orange.shade800,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                l10n.strikesWarning(user.strikesCount),
                style: GoogleFonts.tajawal(
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

  Widget _buildAvatarCard(
    BuildContext context,
    String initials,
    String displayName,
    String phone,
    AppLocalizations l10n,
    AuthState state,
    bool isSeller,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.tajawal(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: GoogleFonts.tajawal(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSeller) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.dinarGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'البائع',
                            style: GoogleFonts.tajawal(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.dinarGold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (phone.isNotEmpty)
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        phone,
                        style: GoogleFonts.tajawal(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      l10n.profileVerified,
                      style: GoogleFonts.tajawal(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.emeraldGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                if (_isEditing) {
                  _isEditing = false;
                } else {
                  _nameController.text = _localName.isNotEmpty
                      ? _localName
                      : (state.displayName ?? '');
                  _isEditing = true;
                }
              }),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _isEditing ? Icons.close_rounded : Icons.edit_outlined,
                  size: 16.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديل الملف الشخصي',
              style: GoogleFonts.tajawal(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _nameController,
              style: GoogleFonts.tajawal(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                labelStyle: GoogleFonts.tajawal(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding:
                      EdgeInsetsDirectional.symmetric(vertical: 12.h),
                ),
                onPressed: () {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty) {
                    setState(() {
                      _localName = newName;
                      _isEditing = false;
                    });
                  }
                },
                child: Text(
                  'حفظ التغييرات',
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isSeller,
  ) {
    final currentLocale = context.read<LocaleCubit>().state;
    final isArabic = currentLocale.languageCode == 'ar';

    final items = <_MenuItem>[
      _MenuItem(
        icon: Icons.location_on_outlined,
        label: 'عناويني',
        onTap: (_) {},
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        label: 'طلباتي',
        onTap: (_) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.favorite_outline,
        label: 'المفضلة',
        onTap: (_) => context.push('/favorites'),
      ),
      if (isSeller)
        _MenuItem(
          icon: Icons.dashboard_outlined,
          label: 'لوحة البائع',
          onTap: (_) => context.push('/seller-dashboard'),
        ),
      _MenuItem(
        icon: Icons.language_outlined,
        label: l10n.profileLanguage,
        onTap: (_) => context.read<LocaleCubit>().toggleLocale(),
        trailing: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 10.w,
            vertical: 4.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            isArabic ? 'العربية' : 'English',
            style: GoogleFonts.tajawal(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'الإعدادات',
        onTap: (_) {},
      ),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 0, 20.w, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                    padding: EdgeInsetsDirectional.only(start: 56.w),
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
    );
  }

  Widget _buildMenuRow(BuildContext context, _MenuItem item) {
    return GestureDetector(
      onTap: item.onTap != null ? () => item.onTap!(context) : null,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppTheme.background,
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
                style: GoogleFonts.tajawal(
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
      padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
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
                style: GoogleFonts.tajawal(
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
