import '../../data/models/auction_models.dart';

abstract class AuctionRepository {
  Future<List<AuctionModel>> getLiveAuctions({int page = 1, int limit = 20});
  Future<AuctionModel> getAuctionDetails(String id);
  Future<List<BidModel>> getBidHistory(
    String id, {
    int page = 1,
    int limit = 20,
  });
  Future<AuctionModel> createAuction(CreateAuctionRequest request);

  // WebSocket Methods
  Future<void> connectToAuction(String auctionId);
  void disconnectFromAuction();
  void placeRealTimeBid(double amount);
  Stream<BidModel> get liveBidStream;
  Stream<String> get auctionErrorStream;
}
