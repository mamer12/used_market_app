// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuctionItemModel _$AuctionItemModelFromJson(Map<String, dynamic> json) =>
    _AuctionItemModel(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      condition: json['condition'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AuctionItemModelToJson(_AuctionItemModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'condition': instance.condition,
      'images': instance.images,
    };

_AuctionModel _$AuctionModelFromJson(
  Map<String, dynamic> json,
) => _AuctionModel(
  id: json['id'] as String?,
  itemId: json['item_id'] as String?,
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  category: json['category'] as String?,
  condition: json['condition'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  startPrice: const _MoneyConverter().fromJson(json['start_price']),
  currentPrice: const _MoneyConverter().fromJson(json['current_price']),
  minBidIncrement: const _MoneyConverter().fromJson(json['min_bid_increment']),
  status: json['status'] as String? ?? 'active',
  startTime: json['start_time'] == null
      ? null
      : DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  winnerId: json['winner_id'] as String?,
);

Map<String, dynamic> _$AuctionModelToJson(_AuctionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'condition': instance.condition,
      'images': instance.images,
      'start_price': _$JsonConverterToJson<Object?, int>(
        instance.startPrice,
        const _MoneyConverter().toJson,
      ),
      'current_price': _$JsonConverterToJson<Object?, int>(
        instance.currentPrice,
        const _MoneyConverter().toJson,
      ),
      'min_bid_increment': _$JsonConverterToJson<Object?, int>(
        instance.minBidIncrement,
        const _MoneyConverter().toJson,
      ),
      'status': instance.status,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'winner_id': instance.winnerId,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_CreateAuctionRequest _$CreateAuctionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateAuctionRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  condition: json['condition'] as String,
  startPrice: (json['start_price'] as num).toInt(),
  minBidIncrement: (json['min_bid_increment'] as num).toInt(),
  durationHours: (json['duration_hours'] as num).toInt(),
);

Map<String, dynamic> _$CreateAuctionRequestToJson(
  _CreateAuctionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'condition': instance.condition,
  'start_price': instance.startPrice,
  'min_bid_increment': instance.minBidIncrement,
  'duration_hours': instance.durationHours,
};

_PlaceBidRequest _$PlaceBidRequestFromJson(Map<String, dynamic> json) =>
    _PlaceBidRequest(amount: (json['amount'] as num).toInt());

Map<String, dynamic> _$PlaceBidRequestToJson(_PlaceBidRequest instance) =>
    <String, dynamic>{'amount': instance.amount};

_BidModel _$BidModelFromJson(Map<String, dynamic> json) => _BidModel(
  id: json['id'] as String,
  auctionId: json['auction_id'] as String?,
  bidderId: json['bidder_id'] as String,
  amount: const _MoneyConverter().fromJson(json['amount']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BidModelToJson(_BidModel instance) => <String, dynamic>{
  'id': instance.id,
  'auction_id': instance.auctionId,
  'bidder_id': instance.bidderId,
  'amount': const _MoneyConverter().toJson(instance.amount),
  'created_at': instance.createdAt.toIso8601String(),
};
