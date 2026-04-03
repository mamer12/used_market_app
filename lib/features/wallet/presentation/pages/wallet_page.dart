import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../cubit/wallet_cubit.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<WalletCubit>()
      ..loadBalance()
      ..loadTransactions();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await HapticFeedback.mediumImpact();
    await _cubit.loadBalance();
    await _cubit.loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppTheme.dinarGold,
            backgroundColor: AppTheme.primary,
            strokeWidth: 2.5,
            displacement: 60,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      20.h,
                      16.w,
                      0,
                    ),
                    child: const _BalanceCard(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.w,
                      16.h,
                      16.w,
                      0,
                    ),
                    child: const _ActionRow(),
                  ),
                ),
                SliverToBoxAdapter(child: _buildEscrowInfoCard()),
                SliverToBoxAdapter(child: _buildSectionHeader('آخر العمليات')),
                const _RealTransactionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.primary,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20.sp,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'محفظتي',
        style: GoogleFonts.tajawal(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
          onPressed: () => context.read<WalletCubit>().loadBalance(),
        ),
      ],
    );
  }

  Widget _buildEscrowInfoCard() {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.emeraldGreen.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: AppTheme.emeraldGreen,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمانة مضمون',
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'فلوسك محمية — ما تنتقل للبائع لحد ما تستلم طلبك',
                  style: GoogleFonts.tajawal(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppTheme.dinarGold,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Balance Card --

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final balanceText = switch (state) {
          WalletLoading() => null,
          WalletError() => '-- د.ع',
          WalletLoaded(:final balanceIqd) =>
            IqdFormatter.format(balanceIqd.toDouble()),
          _ => null,
        };

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.tigrisBlue, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.tigrisBlue.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label row
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppTheme.dinarGold.withValues(alpha: 0.8),
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'رصيد ضمانك',
                    style: GoogleFonts.tajawal(
                      fontSize: 13.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              // Balance amount
              if (state is WalletLoading)
                SkeletonBox(width: 180.w, height: 40.h, borderRadius: 8.r)
              else
                Text(
                  balanceText!,
                  style: GoogleFonts.tajawal(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              SizedBox(height: 4.h),
              Text(
                'دينار عراقي',
                style: GoogleFonts.tajawal(
                  fontSize: 12.sp,
                  color: Colors.white38,
                ),
              ),
              SizedBox(height: 20.h),
              // Badges
              Row(
                children: [
                  const _WhitePill(
                    icon: Icons.lock_rounded,
                    label: 'محمي بأمانة مضمون',
                    iconColor: AppTheme.emeraldGreen,
                  ),
                  SizedBox(width: 8.w),
                  const _WhitePill(
                    icon: Icons.verified_rounded,
                    label: 'موثق',
                    iconColor: AppTheme.dinarGold,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });
  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Action Row --

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.add_rounded,
          label: 'إيداع',
          bg: AppTheme.dinarGold.withValues(alpha: 0.12),
          border: AppTheme.dinarGold.withValues(alpha: 0.30),
          iconColor: const Color(0xFFB8860B),
          labelColor: const Color(0xFF8B6914),
          onTap: () {},
        ),
        SizedBox(width: 10.w),
        _ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'سحب',
          bg: AppTheme.error.withValues(alpha: 0.08),
          border: AppTheme.error.withValues(alpha: 0.20),
          iconColor: AppTheme.error,
          labelColor: AppTheme.error,
          onTap: () {},
        ),
        SizedBox(width: 10.w),
        _ActionButton(
          icon: Icons.swap_horiz_rounded,
          label: 'تحويل',
          bg: AppTheme.matajirBlue.withValues(alpha: 0.08),
          border: AppTheme.matajirBlue.withValues(alpha: 0.20),
          iconColor: AppTheme.matajirBlue,
          labelColor: AppTheme.matajirBlue,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.border,
    required this.iconColor,
    required this.labelColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color bg;
  final Color border;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Real Transactions List --

class _RealTransactionsList extends StatelessWidget {
  const _RealTransactionsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state is WalletTransactionsLoaded) {
          final txns = state.transactions;
          if (txns.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: AppTheme.inactive,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'لا توجد عمليات بعد',
                        style: GoogleFonts.tajawal(
                          fontSize: 14.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return SliverPadding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 100.h),
            sliver: SliverList.separated(
              itemCount: txns.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppTheme.divider),
              itemBuilder: (_, i) => _ApiTransactionRow(tx: txns[i]),
            ),
          );
        }
        // Loading skeleton
        return SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 100.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, _) => Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 10.h),
                child: SkeletonBox(
                  width: double.infinity,
                  height: 48.h,
                  borderRadius: 10.r,
                ),
              ),
              childCount: 5,
            ),
          ),
        );
      },
    );
  }
}

class _ApiTransactionRow extends StatelessWidget {
  const _ApiTransactionRow({required this.tx});
  final Map<String, dynamic> tx;

  String get _title =>
      (tx['title'] as String?) ?? (tx['description'] as String?) ?? 'عملية';
  String get _subtitle =>
      (tx['subtitle'] as String?) ?? (tx['type'] as String?) ?? '';
  String get _date =>
      (tx['created_at'] as String?) ?? (tx['date'] as String?) ?? '';

  bool get _isCredit {
    final type = (tx['type'] as String?)?.toLowerCase();
    if (type == 'credit' ||
        type == 'deposit' ||
        type == 'refund' ||
        type == 'escrow_release') {
      return true;
    }
    if (type == 'debit' ||
        type == 'withdrawal' ||
        type == 'payment' ||
        type == 'escrow_lock') {
      return false;
    }
    final amount = tx['amount'];
    if (amount is num) return amount >= 0;
    return true;
  }

  bool get _isFrozen {
    final type = (tx['type'] as String?)?.toLowerCase();
    return type == 'escrow_lock' || type == 'freeze';
  }

  int get _amount {
    final raw = tx['amount'];
    if (raw is int) return raw.abs();
    if (raw is double) return raw.abs().toInt();
    if (raw is String) return (double.tryParse(raw) ?? 0).abs().toInt();
    return 0;
  }

  Color get _color {
    if (_isFrozen) return AppTheme.matajirBlue;
    return _isCredit ? AppTheme.success : AppTheme.error;
  }

  IconData get _icon {
    if (_isFrozen) return Icons.lock_rounded;
    return _isCredit
        ? Icons.arrow_circle_down_rounded
        : Icons.arrow_circle_up_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _color, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (_subtitle.isNotEmpty)
                  Text(
                    _subtitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_isCredit ? '+' : '-'}${IqdFormatter.format(_amount.toDouble())}',
                style: GoogleFonts.tajawal(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
              if (_date.isNotEmpty)
                Text(
                  _date.length > 10 ? _date.substring(0, 10) : _date,
                  style: GoogleFonts.tajawal(
                    fontSize: 11.sp,
                    color: AppTheme.textTertiary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
