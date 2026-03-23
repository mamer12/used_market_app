import '../../data/models/shop_nearby_model.dart';

abstract class MapRepository {
  Future<List<ShopNearbyModel>> getNearbyShops({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  });
}
