import '../../data/models/shop_models.dart';

abstract class ShopRepository {
  Future<List<ShopModel>> listShops({int page = 1, int limit = 20});
  Future<ShopModel> createShop(CreateShopRequest request);
  Future<ProductModel> addProductToShop(
    String shopId,
    AddProductRequest request,
  );

  /// Returns (shop, products) from the catalog endpoint.
  Future<(ShopModel, List<ProductModel>)> browseShopCatalog(
    String slug, {
    int page = 1,
    int limit = 20,
  });

  /// Convenience: returns only the products list (used by HomeCubit).
  Future<List<ProductModel>> browseShopProducts(
    String slug, {
    int page = 1,
    int limit = 20,
  });
}
