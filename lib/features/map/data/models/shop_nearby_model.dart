class ShopNearbyModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? category;
  final double? latitude;
  final double? longitude;
  final double distanceMeters;
  final String? verificationStatus;

  const ShopNearbyModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.latitude,
    this.longitude,
    required this.distanceMeters,
    this.verificationStatus,
  });

  factory ShopNearbyModel.fromJson(Map<String, dynamic> json) =>
      ShopNearbyModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        imageUrl: json['image_url'] as String?,
        category: json['app_context'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceMeters: (json['distance'] as num?)?.toDouble() ?? 0,
        verificationStatus: json['verification_status'] as String?,
      );

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} كم';
    }
    return '${distanceMeters.toInt()} م';
  }
}
