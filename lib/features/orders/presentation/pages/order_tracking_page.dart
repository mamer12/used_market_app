import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../shop/data/models/order_models.dart';
import '../cubit/order_tracking_cubit.dart';

// ── Matajir design tokens ────────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAFA);
const _kSurface = Colors.white;
const _kBorder = Color(0xFFEDE6DC);
const _kPrimary = Color(0xFF1B4FD8);
const _kGreen = Color(0xFF00B37E);
const _kEscrow = Color(0xFF059669);
const _kTextPrimary = Color(0xFF1C1713);
const _kTextSecondary = Color(0xFF6B5E52);
const _kGold = Color(0xFFC9930A);
const _kOrange = Color(0xFFEA580C);
const _kRed = Color(0xFFDC2626);

/// Order Tracking page showing escrow FSM status with a visual stepper.
///
/// Accepts [orderId] as a route parameter, fetches order details,
/// and displays the escrow lifecycle with action buttons.
class OrderTrackingPage extends StatelessWidget {
  final String orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderTrackingCubit>()..loadOrder(orderId),
      child: _OrderTrackingView(orderId: orderId),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  final String orderId;

  const _OrderTrackingView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _kTextPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.orderTrackingTitle,
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        actions: [
          BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
            builder: (context, state) {
              if (state.status == OrderTrackingStatus.loading ||
                  state.status == OrderTrackingStatus.updating) {
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: 16.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kPrimary,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: _kTextSecondary, size: 22),
                onPressed: () =>
                    context.read<OrderTrackingCubit>().refresh(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
        builder: (context, state) {
          if (state.status == OrderTrackingStatus.loading &&
              state.order == null) {
            return _buildSkeletonLoading();
          }

          if (state.status == OrderTrackingStatus.error &&
              state.order == null) {
            return _buildErrorState(context, state, l10n);
          }

          final order = state.order;
          if (order == null) {
            return _buildErrorState(context, state, l10n);
          }

          return RefreshIndicator(
            color: _kPrimary,
            onRefresh: () => context.read<OrderTrackingCubit>().refresh(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              children: [
                // Order header card
                _buildOrderHeaderCard(order, l10n),
                SizedBox(height: 16.h),

                // Escrow status stepper
                _buildEscrowStepper(order, l10n),
                SizedBox(height: 16.h),

                // Escrow banner
                _buildEscrowBanner(order, l10n),
                SizedBox(height: 16.h),

                // Order details card
                _buildOrderDetailsCard(order, l10n),
                SizedBox(height: 16.h),

                // Action buttons
                _buildActionButtons(context, order, l10n, state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Order header card ───────────────────────────────────────────────────────

  Widget _buildOrderHeaderCard(OrderModel order, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: SizedBox(
              width: 72.w,
              height: 72.w,
              child: order.productImage != null &&
                      order.productImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: order.productImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.shimmerBase,
                        child: Icon(Icons.image_outlined,
                            color: _kTextSecondary, size: 24.sp),
                      ),
                    )
                  : Container(
                      color: AppTheme.shimmerBase,
                      child: Icon(Icons.shopping_bag_outlined,
                          color: _kTextSecondary, size: 24.sp),
                    ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName ?? l10n.orderNumber(order.id.substring(0, 8)),
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${l10n.orderTrackingQty}: ${order.quantity}',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: _kTextSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  IqdFormatter.format(order.totalPrice),
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: _kPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Escrow FSM Stepper ──────────────────────────────────────────────────────

  Widget _buildEscrowStepper(OrderModel order, AppLocalizations l10n) {
    final steps = _getEscrowSteps(order.status, l10n);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderTrackingStatusTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _EscrowStepItem(
              label: step.label,
              color: step.color,
              isActive: step.isActive,
              isCompleted: step.isCompleted,
              isLast: isLast,
              icon: step.icon,
            );
          }),
        ],
      ),
    );
  }

  List<_EscrowStep> _getEscrowSteps(
      OrderStatus status, AppLocalizations l10n) {
    final currentIndex = _statusToIndex(status);

    return [
      _EscrowStep(
        label: l10n.escrowStatusIdle,
        color: Colors.grey,
        icon: Icons.hourglass_empty_rounded,
        isActive: currentIndex == 0,
        isCompleted: currentIndex > 0,
      ),
      _EscrowStep(
        label: l10n.escrowStatusLocked,
        color: _kEscrow,
        icon: Icons.lock_rounded,
        isActive: currentIndex == 1,
        isCompleted: currentIndex > 1,
      ),
      _EscrowStep(
        label: l10n.escrowStatusShipped,
        color: _kPrimary,
        icon: Icons.local_shipping_rounded,
        isActive: currentIndex == 2,
        isCompleted: currentIndex > 2,
      ),
      _EscrowStep(
        label: l10n.escrowStatusDelivered,
        color: _kGreen,
        icon: Icons.check_circle_rounded,
        isActive: currentIndex == 3,
        isCompleted: currentIndex > 3,
      ),
      _EscrowStep(
        label: l10n.escrowStatusReleased,
        color: _kGold,
        icon: Icons.account_balance_wallet_rounded,
        isActive: currentIndex == 4,
        isCompleted: currentIndex > 4,
      ),
      if (status == OrderStatus.disputed)
        _EscrowStep(
          label: l10n.escrowStatusDisputed,
          color: _kRed,
          icon: Icons.gavel_rounded,
          isActive: true,
          isCompleted: false,
        ),
      if (status == OrderStatus.refunded)
        _EscrowStep(
          label: l10n.escrowStatusRefunded,
          color: _kOrange,
          icon: Icons.replay_rounded,
          isActive: true,
          isCompleted: false,
        ),
    ];
  }

  int _statusToIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
      case OrderStatus.pendingCODFulfillment:
        return 0;
      case OrderStatus.paidToEscrow:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
      case OrderStatus.deliveredAndCashCollected:
        return 3;
      case OrderStatus.fundsReleased:
        return 4;
      case OrderStatus.disputed:
        return 2; // Show up to shipped as completed
      case OrderStatus.refunded:
        return 3; // Show up to delivered as completed
    }
  }

  // ── Escrow banner ──────────────────────────────────────────────────────────

  Widget _buildEscrowBanner(OrderModel order, AppLocalizations l10n) {
    final statusInfo = _getStatusBannerInfo(order.status, l10n);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border:
            Border.all(color: statusInfo.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(statusInfo.icon, color: statusInfo.color, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              statusInfo.message,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: statusInfo.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusBannerInfo _getStatusBannerInfo(
      OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.pendingPayment:
      case OrderStatus.pendingCODFulfillment:
        return _StatusBannerInfo(
          message: l10n.escrowBannerIdle,
          color: Colors.grey.shade600,
          icon: Icons.hourglass_empty_rounded,
        );
      case OrderStatus.paidToEscrow:
        return _StatusBannerInfo(
          message: l10n.escrowBannerLocked,
          color: _kEscrow,
          icon: Icons.lock_rounded,
        );
      case OrderStatus.shipped:
        return _StatusBannerInfo(
          message: l10n.escrowBannerShipped,
          color: _kPrimary,
          icon: Icons.local_shipping_rounded,
        );
      case OrderStatus.delivered:
      case OrderStatus.deliveredAndCashCollected:
        return _StatusBannerInfo(
          message: l10n.escrowBannerDelivered,
          color: _kGreen,
          icon: Icons.check_circle_rounded,
        );
      case OrderStatus.fundsReleased:
        return _StatusBannerInfo(
          message: l10n.escrowBannerReleased,
          color: _kGold,
          icon: Icons.account_balance_wallet_rounded,
        );
      case OrderStatus.disputed:
        return _StatusBannerInfo(
          message: l10n.escrowBannerDisputed,
          color: _kRed,
          icon: Icons.gavel_rounded,
        );
      case OrderStatus.refunded:
        return _StatusBannerInfo(
          message: l10n.escrowBannerRefunded,
          color: _kOrange,
          icon: Icons.replay_rounded,
        );
    }
  }

  // ── Order details card ─────────────────────────────────────────────────────

  Widget _buildOrderDetailsCard(OrderModel order, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderTrackingDetails,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          SizedBox(height: 14.h),
          _DetailRow(
            label: l10n.orderTrackingOrderId,
            value: '#${order.id.substring(0, 8).toUpperCase()}',
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            label: l10n.orderTrackingTotal,
            value: IqdFormatter.format(order.totalPrice),
            valueColor: _kPrimary,
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            label: l10n.orderTrackingFulfillment,
            value: order.fulfillmentType == 'delivery'
                ? l10n.orderTrackingDelivery
                : l10n.orderTrackingPickup,
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            label: l10n.orderTrackingCity,
            value: order.shippingAddress.city.isNotEmpty
                ? order.shippingAddress.city
                : '-',
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext context,
    OrderModel order,
    AppLocalizations l10n,
    OrderTrackingState state,
  ) {
    final isUpdating = state.status == OrderTrackingStatus.updating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Confirm delivery button (only when shipped)
        if (order.status == OrderStatus.shipped) ...[
          SizedBox(
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _showConfirmDeliveryDialog(context, order, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                disabledBackgroundColor: _kGreen.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
                elevation: 0,
              ),
              icon: isUpdating
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded,
                      color: Colors.white),
              label: Text(
                l10n.orderTrackingConfirmDelivery,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // Open dispute button (when shipped or delivered)
        if (order.status == OrderStatus.shipped ||
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.deliveredAndCashCollected) ...[
          SizedBox(
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () =>
                  context.push('/orders/${order.id}/dispute'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              icon: Icon(Icons.gavel_rounded, color: _kRed, size: 18.sp),
              label: Text(
                l10n.orderTrackingOpenDispute,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _kRed,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showConfirmDeliveryDialog(
    BuildContext context,
    OrderModel order,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.orderTrackingConfirmDeliveryTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        content: Text(
          l10n.orderTrackingConfirmDeliveryMessage,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: _kTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.orderTrackingCancel,
              style: GoogleFonts.cairo(color: _kTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context
                  .read<OrderTrackingCubit>()
                  .confirmDelivery(order.id);
            },
            child: Text(
              l10n.orderTrackingConfirm,
              style: GoogleFonts.cairo(
                color: _kGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────

  Widget _buildSkeletonLoading() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            height: index == 1 ? 200.h : 100.h,
            decoration: BoxDecoration(
              color: AppTheme.shimmerBase,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      }),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────

  Widget _buildErrorState(
    BuildContext context,
    OrderTrackingState state,
    AppLocalizations l10n,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: _kTextSecondary.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              state.error ?? l10n.orderTrackingError,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                color: _kTextSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<OrderTrackingCubit>().loadOrder(orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              child: Text(
                l10n.retryBtn,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step data model ──────────────────────────────────────────────────────────

class _EscrowStep {
  final String label;
  final Color color;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;

  const _EscrowStep({
    required this.label,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.isCompleted,
  });
}

// ── Step item widget ─────────────────────────────────────────────────────────

class _EscrowStepItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;
  final IconData icon;

  const _EscrowStepItem({
    required this.label,
    required this.color,
    required this.isActive,
    required this.isCompleted,
    required this.isLast,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        (isActive || isCompleted) ? color : Colors.grey.shade300;
    final textColor =
        (isActive || isCompleted) ? _kTextPrimary : _kTextSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator column
        Column(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isActive
                    ? effectiveColor
                    : isCompleted
                        ? effectiveColor.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: effectiveColor,
                  width: isActive ? 2.5 : 1.5,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : icon,
                size: 18.sp,
                color: isActive ? Colors.white : effectiveColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 28.h,
                color: isCompleted
                    ? effectiveColor.withValues(alpha: 0.4)
                    : Colors.grey.shade200,
              ),
          ],
        ),
        SizedBox(width: 14.w),
        // Step label
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 7.h),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Detail row widget ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: _kTextSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? _kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Status banner info ───────────────────────────────────────────────────────

class _StatusBannerInfo {
  final String message;
  final Color color;
  final IconData icon;

  const _StatusBannerInfo({
    required this.message,
    required this.color,
    required this.icon,
  });
}
