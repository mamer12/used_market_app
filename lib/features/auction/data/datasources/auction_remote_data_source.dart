import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/auction_models.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionModel>> getAuctions({
    String? category,
    String? condition,
    String sortBy = 'ending_soon',
    int page = 1,
    int limit = 20,
  });
  Future<AuctionModel> getAuctionDetails(String id);
  Future<List<BidModel>> getBidHistory(
    String id, {
    int page = 1,
    int limit = 20,
  });
  Future<AuctionModel> createAuction(CreateAuctionRequest request);
  Future<BidModel> placeBid(String auctionId, PlaceBidRequest request);
  Future<List<BidModel>> getMyBids();
  Future<List<AuctionModel>> getWatchedAuctions();
}

@LazySingleton(as: AuctionRemoteDataSource)
class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final Dio _dio;

  AuctionRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AuctionModel>> getAuctions({
    String? category,
    String? condition,
    String sortBy = 'ending_soon',
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort_by': sortBy,
    };
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (condition != null && condition.isNotEmpty) {
      queryParams['condition'] = condition;
    }

    final response = await _dio.get(
      ApiConstants.auctions,
      queryParameters: queryParams,
    );
    final data = response.data as List;
    return data
        .map((e) => auctionFromApiResponse(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AuctionModel> getAuctionDetails(String id) async {
    final response = await _dio.get('${ApiConstants.auctions}/$id');
    return auctionFromApiResponse(response.data as Map<String, dynamic>);
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
    return auctionFromApiResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<BidModel> placeBid(String auctionId, PlaceBidRequest request) async {
    final response = await _dio.post(
      '${ApiConstants.auctions}/$auctionId/bids',
      data: request.toJson(),
    );
    return BidModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<BidModel>> getMyBids() async {
    final response = await _dio.get('${ApiConstants.auctions}/my-bids');
    final data = response.data as List;
    return data
        .map((e) => BidModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AuctionModel>> getWatchedAuctions() async {
    final response = await _dio.get('${ApiConstants.auctions}/watchlist');
    final data = response.data as List;
    return data
        .map((e) => auctionFromApiResponse(e as Map<String, dynamic>))
        .toList();
  }
}
