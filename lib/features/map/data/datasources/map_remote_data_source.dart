import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/shop_nearby_model.dart';

abstract class MapRemoteDataSource {
  Future<List<ShopNearbyModel>> getNearbyShops({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  });
}

@LazySingleton(as: MapRemoteDataSource)
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final Dio _dio;

  MapRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ShopNearbyModel>> getNearbyShops({
    required double lat,
    required double lng,
    int radiusMeters = 5000,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'shops',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radiusMeters,
      },
    );
    final data = (res.data?['data'] as List?) ?? [];
    return data
        .map((e) => ShopNearbyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
