import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/order_models.dart';

abstract class OrderRemoteDataSource {
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
}

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSourceImpl(this._dio);

  @override
  Future<OrderModel> buyShopProduct(BuyProductRequest request) async {
    final response = await _dio.post(
      ApiConstants.ordersShop,
      data: request.toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  ) async {
    final response = await _dio.patch(
      '${ApiConstants.ordersShop.split("/shop").first}/$orderId/status',
      data: request.toJson(),
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getMyOrders({
    required String viewAs,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.ordersMe,
      queryParameters: {'view_as': viewAs, 'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
