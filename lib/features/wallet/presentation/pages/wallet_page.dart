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
              _SliverWalletAppBar(),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
                sliver: SliverToBoxAdapter(child: _BalanceCard()),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverToBoxAdapter(child: _ActionRow()),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'آخر العمليات',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                sliver: SliverList.separated(
                  itemCount: _mockTransactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
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
}

// ── Appbar ─────────────────────────────────────────────────────────────────────

class _SliverWalletAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary, size: 20.sp),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'محفظتي',
        style: GoogleFonts.cairo(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              color: AppTheme.textPrimary, size: 22.sp),
          onPressed: () =>
              context.read<WalletCubit>().loadBalance(),
        ),
      ],
    );
  }
}

// ── Balance card ──────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white70, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'الرصيد المتاح',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              switch (state) {
                WalletLoading() => SkeletonBox(
                    width: 160.w,
                    height: 36.h,
                    borderRadius: 8.r,
                  ),
                WalletError() => Text(
                    '-- د.ع',
                    style: GoogleFonts.cairo(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                WalletLoaded(:final balanceIqd) => Text(
                    '${IqdFormatter.format(balanceIqd.toDouble())} ',
                    style: GoogleFonts.cairo(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
              },
              SizedBox(height: 4.h),
              Text(
                'دينار عراقي',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  color: Colors.white60,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 12.sp, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Text(
                          'محمي بأمانة لكطة',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
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

// ── Action row ────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(
          icon: Icons.add_rounded,
          label: 'إيداع',
          color: AppTheme.primary,
          onTap: () {
            // TODO: wire deposit flow
          },
        ),
        SizedBox(width: 12.w),
        _ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'سحب',
          color: AppTheme.error,
          onTap: () {
            // TODO: wire withdraw flow
          },
        ),
        SizedBox(width: 12.w),
        _ActionButton(
          icon: Icons.history_rounded,
          label: 'السجل',
          color: AppTheme.textSecondary,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _TxData {
  final String title;
  final String subtitle;
  final int amount;
  final bool isCredit;
  final String date;

  const _TxData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
  });
}

class _TransactionRow extends StatelessWidget {
  final _TxData tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.isCredit ? AppTheme.success : AppTheme.error;
    final icon =
        tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  tx.subtitle,
                  style: GoogleFonts.cairo(
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
                '${tx.isCredit ? '+' : '-'}${IqdFormatter.format(tx.amount.toDouble())}',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                tx.date,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mock transactions (replace with API when transaction history endpoint exists)

const _mockTransactions = [
  _TxData(
    title: 'إيداع في المحفظة',
    subtitle: 'تم الإيداع بنجاح',
    amount: 150000,
    isCredit: true,
    date: '١٤ مارس',
  ),
  _TxData(
    title: 'شراء منتج',
    subtitle: 'طلب #LQ-4A2F',
    amount: 75000,
    isCredit: false,
    date: '١٣ مارس',
  ),
  _TxData(
    title: 'استرداد طلب',
    subtitle: 'طلب #LQ-8C3E',
    amount: 45000,
    isCredit: true,
    date: '١٢ مارس',
  ),
  _TxData(
    title: 'دفع مزاد',
    subtitle: 'مزاد #AUC-9910',
    amount: 200000,
    isCredit: false,
    date: '١١ مارس',
  ),
  _TxData(
    title: 'مبيعات لكطة',
    subtitle: 'تحرير أمانة',
    amount: 320000,
    isCredit: true,
    date: '١٠ مارس',
  ),
];
