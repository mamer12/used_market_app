import 'package:freezed_annotation/freezed_annotation.dart';

part 'auction_models.freezed.dart';
part 'auction_models.g.dart';

// ── Money converter ────────────────────────────────────────────────────────
// API sends all monetary values as strings ("850000") to avoid JS int overflow.
// We store them as int (Iraqi Dinar, no sub-unit).
class _MoneyConverter implements JsonConverter<int, Object?> {
  const _MoneyConverter();

  @override
  int fromJson(Object? json) {
    if (json == null) return 0;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) return int.tryParse(json) ?? 0;
    return 0;
  }

  @override
  Object toJson(int object) => object; // send as integer
}

// ── AuctionItem (nested `item` object) ────────────────────────────────────

@freezed
abstract class AuctionItemModel with _$AuctionItemModel {
  const factory AuctionItemModel({
    @Default('') String title,
    @Default('') String description,
    String? category,
    String? condition,
    @Default([]) List<String> images,
  }) = _AuctionItemModel;

  factory AuctionItemModel.fromJson(Map<String, dynamic> json) =>
      _$AuctionItemModelFromJson(json);
}

// ── Auction ───────────────────────────────────────────────────────────────

@freezed
abstract class AuctionModel with _$AuctionModel {
  const factory AuctionModel({
    String? id,
    @JsonKey(name: 'item_id') String? itemId,

    // Flattened from nested `item` object via custom fromJson below.
    @Default('') String title,
    @Default('') String description,
    String? category,
    String? condition,
    @Default([]) List<String> images,

    // Monetary fields — API sends as strings.
    @JsonKey(name: 'start_price') @_MoneyConverter() int? startPrice,
    @JsonKey(name: 'current_price') @_MoneyConverter() int? currentPrice,
    @JsonKey(name: 'min_bid_increment') @_MoneyConverter() int? minBidIncrement,

    // Status
    @Default('active') String status,
    @JsonKey(name: 'start_time') DateTime? startTime,
    @JsonKey(name: 'end_time') DateTime? endTime,
    @JsonKey(name: 'winner_id') String? winnerId,

    // Live stream — empty string means no stream active
    @JsonKey(name: 'stream_url') @Default('') String streamUrl,
  }) = _AuctionModel;

  /// Custom fromJson that flattens the nested `item` object so that
  /// [title], [description], [images], [category], and [condition] are
  /// populated directly on the model.
  ///
  /// **Important:** before calling this, callers should merge the nested
  /// `item` map into the top-level JSON — see [AuctionModelX.fromApiResponse].
  factory AuctionModel.fromJson(Map<String, dynamic> json) =>
      _$AuctionModelFromJson(json);
}

// ── Create Auction Request ─────────────────────────────────────────────────
// Aligned with POST /auctions body in the API guide.

@freezed
abstract class CreateAuctionRequest with _$CreateAuctionRequest {
  const factory CreateAuctionRequest({
    required String title,
    required String description,
    required String category,
    required String condition,
    @JsonKey(name: 'start_price') required int startPrice,
    @JsonKey(name: 'min_bid_increment') required int minBidIncrement,
    @JsonKey(name: 'duration_hours') required int durationHours,
    @Default([]) List<String> images,
    @JsonKey(name: 'stream_url') String? streamUrl,
  }) = _CreateAuctionRequest;

  factory CreateAuctionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAuctionRequestFromJson(json);
}

// ── Place Bid Request ──────────────────────────────────────────────────────

@freezed
abstract class PlaceBidRequest with _$PlaceBidRequest {
  const factory PlaceBidRequest({
    required int amount,
  }) = _PlaceBidRequest;

  factory PlaceBidRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceBidRequestFromJson(json);
}

// ── Bid ───────────────────────────────────────────────────────────────────

@freezed
abstract class BidModel with _$BidModel {
  const factory BidModel({
    required String id,
    @JsonKey(name: 'auction_id') String? auctionId,
    @JsonKey(name: 'bidder_id') required String bidderId,
    @_MoneyConverter() required int amount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BidModel;

  factory BidModel.fromJson(Map<String, dynamic> json) =>
      _$BidModelFromJson(json);
}

// ── Helper ────────────────────────────────────────────────────────────────────

/// Parses an [AuctionModel] from the actual API response, which nests the
/// item details inside an `"item"` object.  This helper flattens that sub-map
/// before calling the standard [AuctionModel.fromJson].
AuctionModel auctionFromApiResponse(Map<String, dynamic> json) {
  final item = (json['item'] as Map<String, dynamic>?) ?? <String, dynamic>{};
  return AuctionModel.fromJson(<String, dynamic>{
    ...json,
    if (item.containsKey('title')) 'title': item['title'],
    if (item.containsKey('description')) 'description': item['description'],
    if (item.containsKey('images')) 'images': item['images'],
    if (item.containsKey('category')) 'category': item['category'],
    if (item.containsKey('condition')) 'condition': item['condition'],
  });
}

// ── WebSocket Events (plain classes — no code gen needed) ────────────────────

/// Emitted by [AuctionWebSocketService] when `type == "auction_ended"`.
class AuctionEndedEvent {
  final String auctionId;
  final String? winnerId;
  final int finalPrice;

  const AuctionEndedEvent({
    required this.auctionId,
    this.winnerId,
    required this.finalPrice,
  });
}

/// Wraps a [BidModel] together with the updated [currentPrice] from a
/// `type == "bid_placed"` WebSocket event.
class BidPlacedEvent {
  final BidModel bid;
  final int currentPrice;

  const BidPlacedEvent({required this.bid, required this.currentPrice});
}
