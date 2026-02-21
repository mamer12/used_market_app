import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/shop_models.dart';

abstract class ShopRemoteDataSource {
  Future<ShopModel> createShop(CreateShopRequest request);
  Future<ProductModel> addProductToShop(
    String shopId,
    AddProductRequest request,
  );
  Future<List<ProductModel>> browseShopCatalog(
    String slug, {
    int page = 1,
    int limit = 20,
  });
}

@LazySingleton(as: ShopRemoteDataSource)
class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final Dio _dio;

  ShopRemoteDataSourceImpl(this._dio);

  @override
  Future<ShopModel> createShop(CreateShopRequest request) async {
    final response = await _dio.post(
      ApiConstants.shops,
      data: request.toJson(),
    );
    return ShopModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> addProductToShop(
    String shopId,
    AddProductRequest request,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.shops}/$shopId/products',
      data: request.toJson(),
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> browseShopCatalog(
    String slug, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.shops}/$slug/products',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>;
    return itemsList
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
