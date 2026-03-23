import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/negotiation_model.dart';

abstract class NegotiationRemoteDataSource {
  Future<List<NegotiationModel>> getNegotiations();
  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  });
  Future<bool> acceptNegotiation(String id);
  Future<bool> counterNegotiation(String id, int counterPrice);
  Future<bool> rejectNegotiation(String id);
}

@LazySingleton(as: NegotiationRemoteDataSource)
class NegotiationRemoteDataSourceImpl implements NegotiationRemoteDataSource {
  final Dio _dio;

  NegotiationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NegotiationModel>> getNegotiations() async {
    final res = await _dio.get<Map<String, dynamic>>('negotiations/mine');
    final data = (res.data?['data'] as List?) ?? [];
    return data
        .map((e) => NegotiationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> submitOffer({
    required String productId,
    required int offeredPrice,
  }) async {
    final res = await _dio.post<void>(
      'negotiations',
      data: {'product_id': productId, 'offered_price': offeredPrice},
    );
    return res.statusCode == 201;
  }

  @override
  Future<bool> acceptNegotiation(String id) async {
    final res = await _dio.patch<void>('negotiations/$id/accept');
    return res.statusCode == 200;
  }

  @override
  Future<bool> counterNegotiation(String id, int counterPrice) async {
    final res = await _dio.patch<void>(
      'negotiations/$id/counter',
      data: {'counter_price': counterPrice},
    );
    return res.statusCode == 200;
  }

  @override
  Future<bool> rejectNegotiation(String id) async {
    final res = await _dio.patch<void>('negotiations/$id/reject');
    return res.statusCode == 200;
  }
}
