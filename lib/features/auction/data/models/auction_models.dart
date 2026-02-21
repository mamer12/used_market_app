import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction_models.freezed.dart';
part 'auction_models.g.dart';

@freezed
abstract class AuctionModel with _$AuctionModel {
  const factory AuctionModel({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'current_price') required double currentPrice,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @Default([]) List<String> images,
    // Add other fields as necessary
  }) = _AuctionModel;

  factory AuctionModel.fromJson(Map<String, dynamic> json) =>
      _$AuctionModelFromJson(json);
}

@freezed
abstract class CreateAuctionRequest with _$CreateAuctionRequest {
  const factory CreateAuctionRequest({
    required String title,
    required String description,
    @JsonKey(name: 'starting_price') required double startingPrice,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required List<String> images,
  }) = _CreateAuctionRequest;

  factory CreateAuctionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAuctionRequestFromJson(json);
}

@freezed
abstract class BidModel with _$BidModel {
  const factory BidModel({
    required String id,
    required double amount,
    @JsonKey(name: 'bidder_id') required String bidderId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BidModel;

  factory BidModel.fromJson(Map<String, dynamic> json) =>
      _$BidModelFromJson(json);
}
