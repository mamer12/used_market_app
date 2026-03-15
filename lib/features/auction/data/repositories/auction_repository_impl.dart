import 'package:injectable/injectable.dart';

import '../../domain/repositories/auction_repository.dart';
import '../datasources/auction_remote_data_source.dart';
import '../datasources/auction_websocket_service.dart';
import '../models/auction_models.dart';

@LazySingleton(as: AuctionRepository)
class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource _remoteDataSource;
  final AuctionWebSocketService _webSocketService;

  AuctionRepositoryImpl(this._remoteDataSource, this._webSocketService);

  @override
  Future<List<AuctionModel>> getLiveAuctions({
    String? category,
    String? condition,
    String sortBy = 'ending_soon',
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getAuctions(
      category: category,
      condition: condition,
      sortBy: sortBy,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<AuctionModel> getAuctionDetails(String id) {
    return _remoteDataSource.getAuctionDetails(id);
  }

  @override
  Future<List<BidModel>> getBidHistory(
    String id, {
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getBidHistory(id, page: page, limit: limit);
  }

  @override
  Future<AuctionModel> createAuction(CreateAuctionRequest request) {
    return _remoteDataSource.createAuction(request);
  }

  @override
  Future<BidModel> placeBid(String auctionId, PlaceBidRequest request) {
    return _remoteDataSource.placeBid(auctionId, request);
  }

  @override
  Future<List<BidModel>> getMyBids() async {
    try {
      return await _remoteDataSource.getMyBids();
    } catch (_) {
      // API may not be ready yet — return empty list gracefully.
      return [];
    }
  }

  @override
  Future<List<AuctionModel>> getWatchedAuctions() async {
    try {
      return await _remoteDataSource.getWatchedAuctions();
    } catch (_) {
      // API may not be ready yet — return empty list gracefully.
      return [];
    }
  }

  @override
  Future<void> connectToAuction(String auctionId) {
    return _webSocketService.connect(auctionId);
  }

  @override
  void disconnectFromAuction() {
    _webSocketService.disconnect();
  }

  @override
  void placeRealTimeBid(double amount) {
    _webSocketService.placeBid(amount);
  }

  @override
  Stream<BidPlacedEvent> get liveBidStream => _webSocketService.bidPlacedStream;

  @override
  Stream<AuctionEndedEvent> get auctionEndedStream =>
      _webSocketService.auctionEndedStream;

  @override
  Stream<String> get auctionErrorStream => _webSocketService.errorStream;
}
