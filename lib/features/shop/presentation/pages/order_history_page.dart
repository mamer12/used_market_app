import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeleton_loading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/order_models.dart';
import '../bloc/order_cubit.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderCubit>()..loadOrders(viewAs: 'buyer'),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.profileOrderHistory,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state.status == OrderProcessStatus.loading ||
              state.status == OrderProcessStatus.initial) {
            return _buildSkeleton();
          }

          if (state.status == OrderProcessStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 48.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'تعذّر تحميل الطلبات',
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<OrderCubit>().loadOrders(viewAs: 'buyer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                    child: Text(
                      'إعادة المحاولة',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.orders.isEmpty) {
            return Center(
              child: Text(
                l10n.orderHistoryEmpty,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: AppTheme.inactive,
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.dinarGold,
            backgroundColor: AppTheme.primary,
            onRefresh: () =>
                context.read<OrderCubit>().loadOrders(viewAs: 'buyer'),
            child: ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: state.orders.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 100.w, height: 14.h),
                SkeletonBox(width: 70.w, height: 24.h),
              ],
            ),
            SizedBox(height: 12.h),
            SkeletonBox(width: 160.w, height: 12.h),
            SizedBox(height: 16.h),
            const Divider(color: AppTheme.divider, height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 80.w, height: 14.h),
                SkeletonBox(width: 100.w, height: 16.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  String _statusLabel(AppLocalizations l10n) {
    switch (order.status) {
      case OrderStatus.delivered:
      case OrderStatus.fundsReleased:
      case OrderStatus.deliveredAndCashCollected:
        return l10n.statusDelivered;
      case OrderStatus.pendingPayment:
      case OrderStatus.pendingCODFulfillment:
        return l10n.statusPendingPayment;
      case OrderStatus.refunded:
        return l10n.statusCancelled;
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.paidToEscrow:
        return 'قيد المعالجة';
      case OrderStatus.disputed:
        return 'نزاع';
    }
  }

  Color _statusColor() {
    switch (order.status) {
      case OrderStatus.delivered:
      case OrderStatus.fundsReleased:
      case OrderStatus.deliveredAndCashCollected:
        return AppTheme.success;
      case OrderStatus.pendingPayment:
      case OrderStatus.pendingCODFulfillment:
        return AppTheme.primary;
      case OrderStatus.refunded:
        return AppTheme.error;
      case OrderStatus.shipped:
        return AppTheme.matajirBlue;
      case OrderStatus.paidToEscrow:
        return AppTheme.emeraldGreen;
      case OrderStatus.disputed:
        return AppTheme.ballaPurple;
    }
  }

  String _formattedTotal() {
    final fmt = NumberFormat('#,###', 'ar_IQ');
    return '${fmt.format(order.totalPrice.toInt())} د.ع';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statusColor = _statusColor();

    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderNumber(order.id),
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _statusLabel(l10n),
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (order.productName != null) ...[
            SizedBox(height: 8.h),
            Text(
              order.productName!,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 16.h),
          const Divider(color: AppTheme.divider, height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderTotalAmount,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                _formattedTotal(),
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
