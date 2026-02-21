import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/auction_models.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionModel>> getAuctions({int page = 1, int limit = 20});
  Future<AuctionModel> getAuctionDetails(String id);
  Future<List<BidModel>> getBidHistory(
    String id, {
    int page = 1,
    int limit = 20,
  });
  Future<AuctionModel> createAuction(CreateAuctionRequest request);
}

@LazySingleton(as: AuctionRemoteDataSource)
class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final Dio _dio;

  AuctionRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AuctionModel>> getAuctions({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.auctions,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data
        .map((e) => AuctionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuctionModel> getAuctionDetails(String id) async {
    final response = await _dio.get('${ApiConstants.auctions}/$id');
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BidModel>> getBidHistory(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '${ApiConstants.auctions}/$id/bids',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data as List;
    return data
        .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuctionModel> createAuction(CreateAuctionRequest request) async {
    final response = await _dio.post(
      ApiConstants.auctions,
      data: request.toJson(),
    );
    return AuctionModel.fromJson(response.data as Map<String, dynamic>);
  }
}
