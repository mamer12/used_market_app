import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/auth_guard.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../shop/data/datasources/order_remote_data_source.dart';
import '../../../shop/data/models/order_models.dart';

// ── Orders Cubit ─────────────────────────────────────────────────────────
class OrdersState {
  final bool isLoading;
  final List<OrderModel> orders;
  final String viewAs; // 'buyer' | 'seller'
  final String? error;

  const OrdersState({
    this.isLoading = false,
    this.orders = const [],
    this.viewAs = 'buyer',
    this.error,
  });

  OrdersState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    String? viewAs,
    String? error,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      viewAs: viewAs ?? this.viewAs,
      error: error,
    );
  }
}

@injectable
class OrdersCubit extends Cubit<OrdersState> {
  final OrderRemoteDataSource _dataSource;

  OrdersCubit(this._dataSource) : super(const OrdersState());

  Future<void> loadOrders({
    String viewAs = 'buyer',
    bool refresh = false,
  }) async {
    if (state.isLoading && !refresh) return;
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        viewAs: viewAs,
        orders: refresh ? [] : state.orders,
      ),
    );
    try {
      final orders = await _dataSource.getMyOrders(viewAs: viewAs);
      emit(state.copyWith(isLoading: false, orders: orders));
    } catch (e, st) {
      LogService().error('Failed to load orders', e, st);
      emit(state.copyWith(isLoading: false, error: 'Could not load orders.'));
    }
  }
}

// ── Notifications Page ────────────────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  OrdersCubit? _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      _cubit?.loadOrders(
        viewAs: _tabController.index == 0 ? 'buyer' : 'seller',
        refresh: true,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit?.close();
    super.dispose();
  }

  void _initCubit() {
    if (_cubit == null) {
      _cubit = getIt<OrdersCubit>()..loadOrders(viewAs: 'buyer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (!authState.isAuthenticated) {
              return _buildUnauthenticated();
            }
            _initCubit();
            return BlocProvider.value(
              value: _cubit!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: BlocBuilder<OrdersCubit, OrdersState>(
                      builder: (context, state) {
                        if (state.isLoading && state.orders.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primary,
                            ),
                          );
                        }
                        if (state.error != null && state.orders.isEmpty) {
                          return _buildError(state.error!);
                        }
                        if (state.orders.isEmpty) {
                          return _buildEmpty();
                        }
                        return _buildOrdersList(state.orders);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
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
            l10n.activityPageTitle,
            style: GoogleFonts.cairo(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.inactive.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 20.sp,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.2)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: l10n.activityTabPurchases),
            Tab(text: l10n.activityTabSales),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () => _cubit!.loadOrders(
        viewAs: _tabController.index == 0 ? 'buyer' : 'seller',
        refresh: true,
      ),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        itemCount: orders.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) => _buildOrderCard(orders[i]),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final (statusLabel, statusColor) = _statusInfo(order.status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _statusIcon(order.status),
              size: 22.sp,
              color: statusColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n.orderNumber(
                              order.id.substring(0, 8).toUpperCase(),
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n.orderQtyPrice(
                        order.quantity,
                        order.totalPrice.toInt().toString(),
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _statusInfo(OrderStatus status) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      OrderStatus.pendingPayment => (
        l10n.statusPendingPayment,
        AppTheme.secondary,
      ),
      OrderStatus.paidToEscrow => (
        l10n.statusPaidEscrow,
        const Color(0xFF00BCD4),
      ),
      OrderStatus.shipped => (l10n.statusShipped, AppTheme.primary),
      OrderStatus.delivered => (l10n.statusDelivered, const Color(0xFF4CAF50)),
      OrderStatus.fundsReleased => (
        l10n.statusCompleted,
        const Color(0xFF4CAF50),
      ),
      OrderStatus.pendingCODFulfillment => (
        l10n.statusPendingCODFulfillment,
        AppTheme.secondary,
      ),
      OrderStatus.deliveredAndCashCollected => (
        l10n.statusDeliveredAndCashCollected,
        const Color(0xFF4CAF50),
      ),
    };
  }

  IconData _statusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.pendingPayment => Icons.payment_outlined,
      OrderStatus.paidToEscrow => Icons.lock_outline,
      OrderStatus.shipped => Icons.local_shipping_outlined,
      OrderStatus.delivered => Icons.check_circle_outline,
      OrderStatus.fundsReleased => Icons.verified_outlined,
      OrderStatus.pendingCODFulfillment => Icons.delivery_dining_outlined,
      OrderStatus.deliveredAndCashCollected => Icons.done_all_outlined,
    };
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 36.sp,
              color: AppTheme.inactive,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.ordersEmpty,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.ordersEmptySub,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: AppTheme.error),
          SizedBox(height: 12.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _cubit?.loadOrders(refresh: true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                l10n.retryBtn,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticated() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(40.w, 40.h, 40.w, 120.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 36.sp,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.signInToViewActivity,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.signInActivitySub,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          AuthGuard(
            onAuthenticated: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                l10n.signInBtn,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
