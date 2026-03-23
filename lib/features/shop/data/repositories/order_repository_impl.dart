import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_models.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<OrderModel> buyShopProduct(BuyProductRequest request) {
    return _remoteDataSource.buyShopProduct(request);
  }

  @override
  Future<OrderModel> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  ) {
    return _remoteDataSource.updateOrderStatus(orderId, request);
  }

  @override
  Future<List<OrderModel>> getMyOrders({
    required String viewAs,
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getMyOrders(
      viewAs: viewAs,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<OrderModel> getOrderById(String orderId) {
    return _remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<OrderModel> initiateCODCheckout(String orderId) async {
    try {
      return await _remoteDataSource.initiateCODCheckout(orderId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 402) {
        throw InsufficientWalletException(
          e.response?.data?['error'] ??
              'Your balance is insufficient to cover the COD commission. Please top up your wallet first.',
        );
      }
      throw ApiException(
        e.response?.data?['error'] ?? 'Failed to initiate COD checkout',
      );
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
