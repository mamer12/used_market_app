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
}
