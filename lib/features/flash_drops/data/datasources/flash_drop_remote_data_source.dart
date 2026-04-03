import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/flash_drop_model.dart';

abstract class FlashDropRemoteDataSource {
  Future<List<FlashDropModel>> getActiveFlashDrops();
  Future<void> createFlashDrop({
    required String productId,
    required int discountPct,
    required int slots,
    required DateTime startsAt,
    required DateTime endsAt,
  });
  /// Purchase a flash drop item. Returns the created order ID on success.
  Future<String> purchaseFlashDrop(String flashDropId);
}

@LazySingleton(as: FlashDropRemoteDataSource)
class FlashDropRemoteDataSourceImpl implements FlashDropRemoteDataSource {
  final Dio _dio;

  FlashDropRemoteDataSourceImpl(this._dio);

  @override
  Future<List<FlashDropModel>> getActiveFlashDrops() async {
    final resp = await _dio.get('/api/v1/flash-drops/active');
    final raw = (resp.data['data'] as List?) ?? [];
    return raw
        .map((e) => FlashDropModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createFlashDrop({
    required String productId,
    required int discountPct,
    required int slots,
    required DateTime startsAt,
    required DateTime endsAt,
  }) async {
    await _dio.post('/api/v1/flash-drops', data: {
      'product_id': productId,
      'discount_pct': discountPct,
      'slots': slots,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
    });
  }

  @override
  Future<String> purchaseFlashDrop(String flashDropId) async {
    final resp = await _dio.post('/api/v1/flash-drops/$flashDropId/purchase');
    // Extract order ID from response data
    final data = resp.data['data'] as Map<String, dynamic>?;
    return data?['order_id'] as String? ?? '';
  }
}
