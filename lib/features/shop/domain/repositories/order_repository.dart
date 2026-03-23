import '../../data/models/order_models.dart';

abstract class OrderRepository {
  Future<OrderModel> buyShopProduct(BuyProductRequest request);
  Future<OrderModel> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  );
  Future<List<OrderModel>> getMyOrders({
    required String viewAs,
    int page = 1,
    int limit = 20,
  });
  Future<OrderModel> initiateCODCheckout(String orderId);
  Future<OrderModel> getOrderById(String orderId);
}
