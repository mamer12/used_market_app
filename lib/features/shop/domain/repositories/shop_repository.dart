import '../../data/models/shop_models.dart';

abstract class ShopRepository {
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
