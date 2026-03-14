import '../../data/models/auction_models.dart';

abstract class AuctionRepository {
  Future<List<AuctionModel>> getLiveAuctions({
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

  /// Place a bid via REST (POST /auctions/{id}/bids).
  Future<BidModel> placeBid(String auctionId, PlaceBidRequest request);

  // WebSocket Methods
  Future<void> connectToAuction(String auctionId);
  void disconnectFromAuction();
  void placeRealTimeBid(double amount);
  Stream<BidPlacedEvent> get liveBidStream;
  Stream<AuctionEndedEvent> get auctionEndedStream;
  Stream<String> get auctionErrorStream;
}
