class StoryGroupModel {
  final String shopId;
  final String shopName;
  final String shopLogoUrl;
  final String sooqContext;
  final List<StoryItemModel> stories;
  final bool hasUnwatched;

  StoryGroupModel({
    required this.shopId,
    required this.shopName,
    required this.shopLogoUrl,
    required this.sooqContext,
    required this.stories,
    required this.hasUnwatched,
  });

  factory StoryGroupModel.fromJson(Map<String, dynamic> json) {
    final storiesList = (json['stories'] as List? ?? [json])
        .map((s) => StoryItemModel.fromJson(s as Map<String, dynamic>))
        .toList();
    return StoryGroupModel(
      shopId: json['shop_id'] as String? ?? '',
      shopName: json['shop_name'] as String? ?? '',
      shopLogoUrl: json['shop_logo_url'] as String? ?? '',
      sooqContext: json['sooq_context'] as String? ?? 'matajir',
      stories: storiesList,
      hasUnwatched: storiesList.any((s) => !s.isWatched),
    );
  }
}

class StoryItemModel {
  final String id;
  final String shopId;
  final String mediaUrl;
  final String mediaType;
  final String? productId;
  final int? priceTag;
  final int viewCount;
  final DateTime expiresAt;
  final bool isWatched;

  StoryItemModel({
    required this.id,
    required this.shopId,
    required this.mediaUrl,
    required this.mediaType,
    this.productId,
    this.priceTag,
    required this.viewCount,
    required this.expiresAt,
    required this.isWatched,
  });

  factory StoryItemModel.fromJson(Map<String, dynamic> json) => StoryItemModel(
        id: json['id'] as String,
        shopId: json['shop_id'] as String? ?? '',
        mediaUrl: json['media_url'] as String? ?? '',
        mediaType: json['media_type'] as String? ?? 'image',
        productId: json['product_id'] as String?,
        priceTag: json['price_tag'] as int?,
        viewCount: json['view_count'] as int? ?? 0,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        isWatched: json['is_watched'] as bool? ?? false,
      );
}
