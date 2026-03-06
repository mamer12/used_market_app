import '../../../auction/data/models/auction_models.dart';
import '../../../shop/data/models/shop_models.dart';
// No, Mustamal steals are `ItemModel` which we don't have a clear location for. I'll define a dummy ItemModel or find it.

/// Represents an item in the AnnoucementsCarousel.
class Announcement {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? actionUrl;
  final String? deepLink;
  final String? badgeText;
  final int? colorHex;

  const Announcement({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.actionUrl,
    this.deepLink,
    this.badgeText,
    this.colorHex,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      badgeText: json['badgeText'] as String?,
      colorHex: json['colorHex'] as int?,
    );
  }
}

/// A simplified entity for rendering products inside curations (Bento/Carousel).
class ProductPreview {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String? contextType;

  const ProductPreview({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.contextType,
  });

  factory ProductPreview.fromJson(Map<String, dynamic> json) {
    return ProductPreview(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      contextType: json['contextType'] as String?,
    );
  }
}

/// Dummy ItemModel for Mustamal items since not explicitly defined yet
class ItemModel {
  final String id;
  final String title;
  final List<String> images;
  final num price;
  final String? condition;

  const ItemModel({
    required this.id,
    required this.title,
    required this.images,
    required this.price,
    this.condition,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      price: json['price'] as num? ?? 0,
      condition: json['condition'] as String?,
    );
  }
}

/// A parsed response from the unified /mobile/home endpoint
class SuperAppPortalResponse {
  final List<AuctionModel> mazadat;
  final List<ItemModel> mustamal;
  final List<ShopModel> matajir;
  final List<ProductModel> balla;
  final List<Announcement> announcements;

  const SuperAppPortalResponse({
    this.mazadat = const [],
    this.mustamal = const [],
    this.matajir = const [],
    this.balla = const [],
    this.announcements = const [],
  });

  static const SuperAppPortalResponse empty = SuperAppPortalResponse();

  factory SuperAppPortalResponse.fromJson(Map<String, dynamic> json) {
    return SuperAppPortalResponse(
      mazadat:
          (json['mazadat'] as List<dynamic>?)
              ?.map((e) => AuctionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      mustamal:
          (json['mustamal'] as List<dynamic>?)
              ?.map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      matajir:
          (json['matajir'] as List<dynamic>?)
              ?.map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      balla:
          (json['balla'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      announcements:
          (json['announcements'] as List<dynamic>?)
              ?.map((e) => Announcement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
