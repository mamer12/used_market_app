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

  /// Fetch the current user's bid history (all statuses).
  Future<List<BidModel>> getMyBids();

  /// Fetch auctions the user is watching.
  Future<List<AuctionModel>> getWatchedAuctions();

  // WebSocket Methods
  Future<void> connectToAuction(String auctionId);
  void disconnectFromAuction();
  void placeRealTimeBid(double amount);
  Stream<BidPlacedEvent> get liveBidStream;
  Stream<AuctionEndedEvent> get auctionEndedStream;
  Stream<String> get auctionErrorStream;

  /// Accept a second-chance offer for an auction where the winner failed to pay.
  Future<AuctionModel> acceptSecondChance(String auctionId);
}
