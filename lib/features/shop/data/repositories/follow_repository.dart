import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/shop_models.dart';

/// Repository for shop follow/unfollow operations.
///
/// Endpoints:
///   POST   /api/v1/shops/:id/follow
///   DELETE /api/v1/shops/:id/follow
///   GET    /api/v1/shops/following
///   GET    /api/v1/shops/:id/followers/count
@injectable
class FollowRepository {
  final Dio _dio;

  FollowRepository(this._dio);

  /// Follow a shop. Returns `true` on success.
  Future<bool> followShop(String shopId) async {
    try {
      final res = await _dio.post('/api/v1/shops/$shopId/follow');
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Unfollow a shop. Returns `true` on success.
  Future<bool> unfollowShop(String shopId) async {
    try {
      final res = await _dio.delete('/api/v1/shops/$shopId/follow');
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// Fetch list of followed shops with their products.
  Future<List<ProductModel>> fetchFollowingProducts({int page = 1}) async {
    try {
      final res = await _dio.get(
        '/api/v1/shops/following/products',
        queryParameters: {'page': page, 'limit': 20},
      );
      final raw = (res.data['data'] as List?) ?? [];
      return raw
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Check if current user follows a specific shop.
  Future<bool> isFollowing(String shopId) async {
    try {
      final res = await _dio.get('/api/v1/shops/$shopId/follow/status');
      return res.data['following'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }
}
