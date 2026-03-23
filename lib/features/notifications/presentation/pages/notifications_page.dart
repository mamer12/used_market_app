import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/iqd_formatter.dart';
import '../../../../core/widgets/skeleton_loading.dart';
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
    _cubit ??= getIt<OrdersCubit>()..loadOrders(viewAs: 'buyer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Router guard ensures only authenticated users reach this page.
            _initCubit();
            return BlocProvider.value(
              value: _cubit!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: BlocBuilder<OrdersCubit, OrdersState>(
                      builder: (context, state) {
                        return CustomScrollView(
                          slivers: [
                            if (state.isLoading && state.orders.isEmpty)
                              const OrdersListSkeleton()
                            else if (state.error != null &&
                                state.orders.isEmpty)
                              SliverFillRemaining(
                                child: _buildError(state.error!),
                              )
                            else if (state.orders.isEmpty)
                              SliverFillRemaining(child: _buildEmpty())
                            else
                              SliverPadding(
                                padding: EdgeInsets.all(16.w),
                                sliver: SliverList.separated(
                                  itemCount: state.orders.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.h),
                                  itemBuilder: (_, i) =>
                                      _buildOrderCard(state.orders[i]),
                                ),
                              ),
                            if (!state.isLoading && state.orders.isNotEmpty)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  8.h,
                                  16.w,
                                  100.h,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildPromoBanner(),
                                ),
                              ),
                          ],
                        );
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'النشاط',
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {},
              child: Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.background,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 24.sp,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.inactive.withValues(alpha: 0.1)),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: AppTheme.primary, width: 3),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'مشترياتي'),
            Tab(text: 'مبيعاتي'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final (statusLabel, statusColor) = _statusInfo(order.status);
    final statusIcon = _statusIcon(order.status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inactive.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(statusIcon, size: 28.sp, color: statusColor),
          ),
          SizedBox(width: 16.w),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      IqdFormatter.format(order.totalPrice.toDouble()),
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'LQ-${order.id.length > 4 ? order.id.substring(order.id.length - 4).toUpperCase() : order.id.toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'الكمية: ${order.quantity} | قيد المعالجة',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.chevron_left_rounded,
            color: AppTheme.inactive.withValues(alpha: 0.5),
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 150.sp,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تتبع طلباتك بسهولة',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'حدث التطبيق للحصول على ميزات جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _statusInfo(OrderStatus status) {
    return switch (status) {
      OrderStatus.pendingPayment => ('بانتظار الدفع', Colors.orange),
      OrderStatus.paidToEscrow => ('تم الدفع', Colors.cyan),
      OrderStatus.shipped => ('تم الشحن', Colors.blue),
      OrderStatus.delivered => ('تم التوصيل', Colors.green),
      OrderStatus.fundsReleased => ('مكتمل', Colors.green),
      OrderStatus.pendingCODFulfillment => ('قيد المعالجة', Colors.orange),
      OrderStatus.deliveredAndCashCollected => ('مكتمل', Colors.green),
      OrderStatus.disputed => ('نزاع', Colors.red),
      OrderStatus.refunded => ('مسترد', Colors.orange),
    };
  }

  IconData _statusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.pendingPayment => Icons.schedule_rounded,
      OrderStatus.paidToEscrow => Icons.lock_outline_rounded,
      OrderStatus.shipped => Icons.local_shipping_rounded,
      OrderStatus.delivered => Icons.check_circle_rounded,
      OrderStatus.fundsReleased => Icons.verified_rounded,
      OrderStatus.pendingCODFulfillment => Icons.delivery_dining_rounded,
      OrderStatus.deliveredAndCashCollected => Icons.done_all_rounded,
      OrderStatus.disputed => Icons.report_problem_rounded,
      OrderStatus.refunded => Icons.undo_rounded,
    };
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.inactive.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 36.sp,
              color: AppTheme.inactive,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد تشاط',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'قم بالشراء أو البيع لتبدأ',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48.sp, color: AppTheme.error),
          SizedBox(height: 16.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _cubit?.loadOrders(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
