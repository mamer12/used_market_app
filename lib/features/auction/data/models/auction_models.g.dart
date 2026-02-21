// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuctionModel _$AuctionModelFromJson(Map<String, dynamic> json) =>
    _AuctionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      endTime: DateTime.parse(json['end_time'] as String),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AuctionModelToJson(_AuctionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'current_price': instance.currentPrice,
      'end_time': instance.endTime.toIso8601String(),
      'images': instance.images,
    };

_CreateAuctionRequest _$CreateAuctionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateAuctionRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  startingPrice: (json['starting_price'] as num).toDouble(),
  endTime: DateTime.parse(json['end_time'] as String),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CreateAuctionRequestToJson(
  _CreateAuctionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'starting_price': instance.startingPrice,
  'end_time': instance.endTime.toIso8601String(),
  'images': instance.images,
};

_BidModel _$BidModelFromJson(Map<String, dynamic> json) => _BidModel(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  bidderId: json['bidder_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BidModelToJson(_BidModel instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'bidder_id': instance.bidderId,
  'created_at': instance.createdAt.toIso8601String(),
};
