import 'package:injectable/injectable.dart';

import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_data_source.dart';
import '../models/shop_nearby_model.dart';

@LazySingleton(as: MapRepository)
class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource _remoteDataSource;

  MapRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ShopNearbyModel>> getNearbyShops({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  }) =>
      _remoteDataSource.getNearbyShops(
        lat: lat,
        lng: lng,
        radiusMeters: radiusMeters,
      );
}
