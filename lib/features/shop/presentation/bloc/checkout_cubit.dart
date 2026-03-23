import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/order_models.dart';
import '../../domain/repositories/order_repository.dart';

// ── States ────────────────────────────────────────────────────────────────────

enum CheckoutProcessStatus { initial, loading, success, error }

class CheckoutState {
  final CheckoutProcessStatus status;
  final String? orderId;
  final String? paymentUrl;
  final String? paymentMethod;
  final String? error;

  const CheckoutState({
    this.status = CheckoutProcessStatus.initial,
    this.orderId,
    this.paymentUrl,
    this.paymentMethod,
    this.error,
  });

  CheckoutState copyWith({
    CheckoutProcessStatus? status,
    String? orderId,
    String? paymentUrl,
    String? paymentMethod,
    String? error,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      error: error,
    );
  }
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRepository _orderRepository;

  CheckoutCubit(this._orderRepository) : super(const CheckoutState());

  /// Creates an order via the API and handles COD vs ZainCash routing.
  ///
  /// - COD: creates order + initiates COD checkout, emits success with orderId.
  /// - ZainCash: creates order with payment_method = "zaincash", emits success
  ///   with orderId + paymentUrl for WebView navigation.
  Future<void> placeOrder(
    BuyProductRequest request, {
    required String paymentMethod,
  }) async {
    emit(state.copyWith(
      status: CheckoutProcessStatus.loading,
      error: null,
    ));

    try {
      final orderRequest = BuyProductRequest(
        productId: request.productId,
        quantity: request.quantity,
        shippingAddress: request.shippingAddress,
        fulfillmentType: request.fulfillmentType,
        appContext: request.appContext,
        paymentMethod: paymentMethod,
      );

      final order = await _orderRepository.buyShopProduct(orderRequest);

      if (paymentMethod == 'cod') {
        await _orderRepository.initiateCODCheckout(order.id);
        emit(state.copyWith(
          status: CheckoutProcessStatus.success,
          orderId: order.id,
          paymentMethod: paymentMethod,
        ));
      } else {
        // ZainCash or other payment methods — server returns a payment_url
        emit(state.copyWith(
          status: CheckoutProcessStatus.success,
          orderId: order.id,
          paymentUrl: order.paymentUrl,
          paymentMethod: paymentMethod,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CheckoutProcessStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Resets the cubit to initial state for retry.
  void reset() {
    emit(const CheckoutState());
  }
}
