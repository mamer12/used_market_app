/// A single polymorphic item in the personalized feed.
class FeedItem {
  final String kind; // "auction" | "product"
  final String id;
  final String? shopId;
  final String title;
  final String category;
  final List<String> images;
  final int price;
  final String? endTime;

  const FeedItem({
    required this.kind,
    required this.id,
    this.shopId,
    required this.title,
    required this.category,
    required this.images,
    required this.price,
    this.endTime,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      kind: json['kind'] as String? ?? 'product',
      id: json['id'] as String? ?? '',
      shopId: json['shop_id'] as String?,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      endTime: json['end_time'] as String?,
    );
  }
}

/// Response envelope from GET /api/v1/feed/for-you.
class PersonalizedFeedResponse {
  final bool personalized;
  final List<FeedItem> items;

  const PersonalizedFeedResponse({
    required this.personalized,
    required this.items,
  });

  factory PersonalizedFeedResponse.fromJson(Map<String, dynamic> json) {
    return PersonalizedFeedResponse(
      personalized: json['personalized'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
