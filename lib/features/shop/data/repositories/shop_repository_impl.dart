import 'package:injectable/injectable.dart';

import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_data_source.dart';
import '../models/shop_models.dart';

@LazySingleton(as: ShopRepository)
class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource _remoteDataSource;

  ShopRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ShopModel>> listShops({int page = 1, int limit = 20}) {
    return _remoteDataSource.listShops(page: page, limit: limit);
  }

  @override
  Future<ShopModel> createShop(CreateShopRequest request) {
    return _remoteDataSource.createShop(request);
  }

  @override
  Future<ProductModel> addProductToShop(
    String shopId,
    AddProductRequest request,
  ) {
    return _remoteDataSource.addProductToShop(shopId, request);
  }

  @override
  Future<(ShopModel, List<ProductModel>)> browseShopCatalog(
    String slug, {
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.browseShopCatalog(slug, page: page, limit: limit);
  }

  @override
  Future<List<ProductModel>> browseShopProducts(
    String slug, {
    int page = 1,
    int limit = 20,
  }) async {
    final (_, products) = await _remoteDataSource.browseShopCatalog(
      slug,
      page: page,
      limit: limit,
    );
    return products;
  }
}
