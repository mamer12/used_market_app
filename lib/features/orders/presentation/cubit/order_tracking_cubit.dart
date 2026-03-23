import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../shop/data/models/order_models.dart';
import '../../../shop/domain/repositories/order_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

enum OrderTrackingStatus { initial, loading, loaded, updating, error }

class OrderTrackingState {
  final OrderTrackingStatus status;
  final OrderModel? order;
  final String? error;

  const OrderTrackingState({
    this.status = OrderTrackingStatus.initial,
    this.order,
    this.error,
  });

  OrderTrackingState copyWith({
    OrderTrackingStatus? status,
    OrderModel? order,
    String? error,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      order: order ?? this.order,
      error: error,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final OrderRepository _orderRepository;

  OrderTrackingCubit(this._orderRepository)
      : super(const OrderTrackingState());

  /// Fetches order details by [orderId].
  Future<void> loadOrder(String orderId) async {
    emit(state.copyWith(status: OrderTrackingStatus.loading, error: null));
    try {
      final order = await _orderRepository.getOrderById(orderId);
      emit(state.copyWith(
        status: OrderTrackingStatus.loaded,
        order: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderTrackingStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Confirms delivery — sends PATCH to update status to "delivered".
  Future<void> confirmDelivery(String orderId) async {
    emit(state.copyWith(status: OrderTrackingStatus.updating, error: null));
    try {
      final updated = await _orderRepository.updateOrderStatus(
        orderId,
        const UpdateOrderStatusRequest(status: OrderStatus.delivered),
      );
      emit(state.copyWith(
        status: OrderTrackingStatus.loaded,
        order: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderTrackingStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Refreshes the current order.
  Future<void> refresh() async {
    final currentOrderId = state.order?.id;
    if (currentOrderId == null) return;
    await loadOrder(currentOrderId);
  }
}
