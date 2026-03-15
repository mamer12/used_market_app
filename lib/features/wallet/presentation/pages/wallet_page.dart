import 'package:flutter/material.dart';
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
    _cubit = getIt<WalletCubit>()..loadBalance();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
                  child: _BalanceCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: _ActionRow(),
                ),
              ),
              SliverToBoxAdapter(child: _buildEscrowInfoCard()),
              SliverToBoxAdapter(child: _buildSectionHeader('آخر العمليات')),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                sliver: SliverList.separated(
                  itemCount: _mockTransactions.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppTheme.divider),
                  itemBuilder: (_, i) =>
                      _TransactionRow(tx: _mockTransactions[i]),
                ),
              ),
            ],
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
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20.sp),
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
          icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 22.sp),
          onPressed: () => context.read<WalletCubit>().loadBalance(),
        ),
      ],
    );
  }

  Widget _buildEscrowInfoCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.emeraldGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
            color: AppTheme.emeraldGreen.withValues(alpha: 0.25)),
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
            child: Icon(Icons.shield_rounded,
                color: AppTheme.emeraldGreen, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أمانة لكطة',
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
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppTheme.primary,
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

// ── Balance Card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final balanceText = switch (state) {
          WalletLoading() => null,
          WalletError() => '-- د.ع',
          WalletLoaded(:final balanceIqd) =>
            '${IqdFormatter.format(balanceIqd.toDouble())} د.ع',
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
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white60, size: 16.sp),
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
                    fontSize: 12.sp, color: Colors.white38),
              ),
              SizedBox(height: 20.h),
              // Escrow lock chip + Dinar Gold badge
              Row(
                children: [
                  const _WhitePill(
                    icon: Icons.lock_rounded,
                    label: 'محمي بأمانة لكطة',
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
  const _WhitePill(
      {required this.icon, required this.label, required this.iconColor});
  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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

// ── Action Row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.add_rounded,
          label: 'إيداع',
          bg: AppTheme.dinarGold.withValues(alpha: 0.12),
          border: AppTheme.dinarGold.withValues(alpha: 0.30),
          iconColor: const Color(0xFFB8860B), // dark gold
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
          icon: Icons.history_rounded,
          label: 'السجل',
          bg: AppTheme.surface,
          border: AppTheme.divider,
          iconColor: AppTheme.textSecondary,
          labelColor: AppTheme.textSecondary,
          onTap: () {},
        ),
        SizedBox(width: 10.w),
        _ActionButton(
          icon: Icons.share_rounded,
          label: 'مشاركة',
          bg: AppTheme.surface,
          border: AppTheme.divider,
          iconColor: AppTheme.textSecondary,
          labelColor: AppTheme.textSecondary,
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
          padding: EdgeInsets.symmetric(vertical: 14.h),
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

// ── Transaction Row ───────────────────────────────────────────────────────────

class _TxData {
  final String title;
  final String subtitle;
  final int amount;
  final bool isCredit;
  final String date;
  final _TxType type;

  const _TxData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    this.type = _TxType.transfer,
  });
}

enum _TxType { deposit, withdraw, escrowLock, escrowRelease, transfer, refund }

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});
  final _TxData tx;

  IconData get _icon => switch (tx.type) {
        _TxType.deposit => Icons.add_circle_outline_rounded,
        _TxType.withdraw => Icons.arrow_circle_up_rounded,
        _TxType.escrowLock => Icons.lock_rounded,
        _TxType.escrowRelease => Icons.lock_open_rounded,
        _TxType.refund => Icons.undo_rounded,
        _TxType.transfer => tx.isCredit
            ? Icons.arrow_circle_down_rounded
            : Icons.arrow_circle_up_rounded,
      };

  Color get _color => switch (tx.type) {
        _TxType.escrowLock => AppTheme.tigrisBlue,
        _TxType.escrowRelease => AppTheme.emeraldGreen,
        _TxType.refund => AppTheme.dinarGold,
        _ => tx.isCredit ? AppTheme.success : AppTheme.error,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
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
                  tx.title,
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  tx.subtitle,
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
                '${tx.isCredit ? '+' : '-'}${IqdFormatter.format(tx.amount.toDouble())} د.ع',
                style: GoogleFonts.tajawal(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
              Text(
                tx.date,
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

// ── Mock data ─────────────────────────────────────────────────────────────────

const _mockTransactions = [
  _TxData(
    title: 'إيداع في المحفظة',
    subtitle: 'تم الإيداع بنجاح عبر ZainCash',
    amount: 150000,
    isCredit: true,
    date: '١٤ مارس',
    type: _TxType.deposit,
  ),
  _TxData(
    title: 'حجز أمانة — طلب #LQ-4A2F',
    subtitle: 'المبلغ محجوز حتى استلام الطلب',
    amount: 75000,
    isCredit: false,
    date: '١٣ مارس',
    type: _TxType.escrowLock,
  ),
  _TxData(
    title: 'تحرير أمانة — طلب #LQ-3B1C',
    subtitle: 'تم تحويل المبلغ للبائع بعد الاستلام',
    amount: 45000,
    isCredit: true,
    date: '١٢ مارس',
    type: _TxType.escrowRelease,
  ),
  _TxData(
    title: 'دفع مزاد #AUC-9910',
    subtitle: 'فوز بالمزاد — قيد الشحن',
    amount: 200000,
    isCredit: false,
    date: '١١ مارس',
    type: _TxType.withdraw,
  ),
  _TxData(
    title: 'استرداد طلب #LQ-8C3E',
    subtitle: 'تم رد المبلغ بعد نزاع ناجح',
    amount: 320000,
    isCredit: true,
    date: '١٠ مارس',
    type: _TxType.refund,
  ),
];
