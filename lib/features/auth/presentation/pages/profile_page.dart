import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auction/presentation/pages/active_bids_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../shop/data/datasources/order_remote_data_source.dart';
import '../../../shop/data/models/order_models.dart';
import '../../../shop/presentation/pages/order_history_page.dart';
import '../../data/models/auth_models.dart';

final _iqFormat = NumberFormat('#,###', 'ar_IQ');

// ── Page ──────────────────────────────────────────────────────────────────────

/// Me tab — user profile from local auth state + /users/me endpoint.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  String _localName = '';

  // Real orders loaded from API
  List<OrderModel>? _orders;
  bool _ordersLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final ds = getIt<OrderRemoteDataSource>();
      final orders = await ds.getMyOrders(viewAs: 'buyer', limit: 3);
      if (mounted) setState(() { _orders = orders; _ordersLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _orders = []; _ordersLoading = false; });
    }
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

  // ── Authenticated ────────────────────────────────────────
  Widget _buildProfile(BuildContext context, AuthState state) {
    final l10n = AppLocalizations.of(context);
    final displayName =
        _localName.isNotEmpty ? _localName : (state.displayName ?? 'User');
    final phone = state.phoneNumber ?? '';
    final initials = _getInitials(displayName);
    final isSeller = state.user?.role == 'seller';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        if (state.user != null)
          SliverToBoxAdapter(
            child: _buildStrikesBanner(context, state.user!, l10n),
          ),
        SliverToBoxAdapter(
          child: _buildAvatar(context, initials, displayName, phone, l10n, state),
        ),
        if (_isEditing)
          SliverToBoxAdapter(child: _buildEditForm(context, l10n)),
        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
        SliverToBoxAdapter(child: _buildOrdersSection(context)),
        SliverToBoxAdapter(child: SizedBox(height: 12.h)),
        if (isSeller)
          SliverToBoxAdapter(child: _buildSellerDashboard(context)),
        if (isSeller)
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
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
    BuildContext context,
    String initials,
    String displayName,
    String phone,
    AppLocalizations l10n,
    AuthState state,
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
                  SizedBox(height: 4.h),
                  if (state.user?.walletBalance != null)
                    Text(
                      '${_iqFormat.format(int.tryParse(state.user!.walletBalance) ?? 0)} د.ع',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.success,
                      ),
                    ),
                  SizedBox(height: 4.h),
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
            GestureDetector(
              onTap: () => setState(() {
                if (_isEditing) {
                  _isEditing = false;
                } else {
                  _nameController.text =
                      _localName.isNotEmpty ? _localName : (state.displayName ?? '');
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
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
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
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _nameController,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                labelStyle: GoogleFonts.cairo(
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
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
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
                  style: GoogleFonts.cairo(
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

  Widget _buildOrdersSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلباتي',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                ),
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (_ordersLoading)
            Column(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: SkeletonBox(
                    width: double.infinity,
                    height: 62.h,
                    borderRadius: 12.r,
                  ),
                ),
              ),
            )
          else if (_orders == null || _orders!.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'لا توجد طلبات بعد',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            ..._orders!.map((order) => _buildApiOrderRow(order)),
        ],
      ),
    );
  }

  // Maps API OrderStatus enum to Arabic label + colour
  (String, Color) _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return ('بانتظار الدفع', const Color(0xFFD97706));
      case OrderStatus.paidToEscrow:
        return ('تم الدفع', const Color(0xFF16A34A));
      case OrderStatus.shipped:
        return ('تم الشحن', const Color(0xFF1B4FD8));
      case OrderStatus.delivered:
      case OrderStatus.fundsReleased:
        return ('تم التسليم', const Color(0xFF6B7280));
      case OrderStatus.pendingCODFulfillment:
        return ('دفع عند الاستلام', const Color(0xFF7C3AED));
      case OrderStatus.deliveredAndCashCollected:
        return ('مكتمل', const Color(0xFF6B7280));
    }
  }

  Widget _buildApiOrderRow(OrderModel order) {
    final (label, color) = _statusLabel(order.status);
    final priceStr = '${_iqFormat.format(order.totalPrice.toInt())} د.ع';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id}',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  order.shippingAddress.city,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                priceStr,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerDashboard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة تحكم البائع',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'إجمالي المبيعات',
                  value: '42',
                  icon: Icons.receipt_long_outlined,
                  color: AppTheme.matajirBlue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  label: 'الإيرادات',
                  value: '${_iqFormat.format(1250000)} د.ع',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
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
        onTap: (_) => setState(() {
          final authState = context.read<AuthBloc>().state;
          _nameController.text =
              _localName.isNotEmpty ? _localName : (authState.displayName ?? '');
          _isEditing = !_isEditing;
        }),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
          );
        },
      ),
      _MenuItem(
        icon: Icons.gavel_outlined,
        label: l10n.profileActiveBids,
        onTap: (_) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActiveBidsPage()),
          );
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
