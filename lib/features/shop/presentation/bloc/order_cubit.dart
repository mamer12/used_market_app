import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/order_models.dart';
import '../../domain/repositories/order_repository.dart';

enum OrderProcessStatus { initial, loading, success, error }

class OrderState {
  final OrderProcessStatus status;
  final List<OrderModel> orders;
  final String? error;

  const OrderState({
    this.status = OrderProcessStatus.initial,
    this.orders = const [],
    this.error,
  });

  OrderState copyWith({
    OrderProcessStatus? status,
    List<OrderModel>? orders,
    String? error,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }
}

@injectable
class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit(this._orderRepository) : super(const OrderState());

  Future<void> buyProduct(
    BuyProductRequest request, {
    bool isCOD = false,
  }) async {
    emit(state.copyWith(status: OrderProcessStatus.loading));
    try {
      final order = await _orderRepository.buyShopProduct(request);
      if (isCOD) {
        await _orderRepository.initiateCODCheckout(order.id);
      }
      emit(state.copyWith(status: OrderProcessStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: OrderProcessStatus.error, error: e.toString()),
      );
    }
  }

  Future<void> loadOrders({required String viewAs}) async {
    emit(state.copyWith(status: OrderProcessStatus.loading));
    try {
      final orders = await _orderRepository.getMyOrders(viewAs: viewAs);
      emit(state.copyWith(status: OrderProcessStatus.success, orders: orders));
    } catch (e) {
      emit(
        state.copyWith(status: OrderProcessStatus.error, error: e.toString()),
      );
    }
  }
}
