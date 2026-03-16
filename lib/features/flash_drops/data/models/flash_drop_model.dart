class FlashDropModel {
  final String id;
  final String shopName;
  final String productName;
  final String productImageUrl;
  final int originalPrice;
  final int flashPrice;
  final DateTime endsAt;
  final int? stockLimit;

  FlashDropModel({
    required this.id,
    required this.shopName,
    required this.productName,
    required this.productImageUrl,
    required this.originalPrice,
    required this.flashPrice,
    required this.endsAt,
    this.stockLimit,
  });

  factory FlashDropModel.fromJson(Map<String, dynamic> json) => FlashDropModel(
        id: json['id'] as String,
        shopName: json['shop_name'] as String? ?? '',
        productName: json['product_name'] as String? ?? '',
        productImageUrl: json['product_image_url'] as String? ?? '',
        originalPrice: json['original_price'] as int? ?? 0,
        flashPrice: json['flash_price'] as int? ?? 0,
        endsAt: DateTime.parse(json['ends_at'] as String),
        stockLimit: json['stock_limit'] as int?,
      );

  Duration get remaining => endsAt.difference(DateTime.now());
  bool get isExpired => remaining.isNegative;
}
