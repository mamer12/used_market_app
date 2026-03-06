import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_models.freezed.dart';
part 'shop_models.g.dart';

// ── Price Converter ────────────────────────────────────────────────────────
// The API returns price as a numeric-string (e.g. "50000").
class _PriceConverter implements JsonConverter<double, Object> {
  const _PriceConverter();

  @override
  double fromJson(Object json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) return double.tryParse(json) ?? 0.0;
    return 0.0;
  }

  @override
  Object toJson(double object) => object.toInt(); // send as int to API
}

// ── Shop ──────────────────────────────────────────────────────────────────
@freezed
abstract class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? category,
    @JsonKey(name: 'owner_id') String? ownerId,
    @JsonKey(name: 'contact_number') String? contactNumber,
    @JsonKey(name: 'location_city') String? locationCity,
    @JsonKey(name: 'location_district') String? locationDistrict,
    @JsonKey(name: 'location_address') String? locationAddress,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'shop_type') String? shopType, // 'physical' or 'digital'
    @JsonKey(name: 'verification_status') String? verificationStatus,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'instagram_url') String? instagramUrl,
    @JsonKey(name: 'opening_hours') dynamic openingHours,
    @JsonKey(name: 'id_card_url') String? idCardUrl,
    @JsonKey(name: 'storefront_url') String? storefrontUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ShopModel;

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);
}

@freezed
abstract class CreateShopRequest with _$CreateShopRequest {
  const factory CreateShopRequest({
    required String name,
    required String slug,
    String? description,
    String? category,
    @JsonKey(name: 'contact_number') String? contactNumber,
    @JsonKey(name: 'location_city') String? locationCity,
    @JsonKey(name: 'location_district') String? locationDistrict,
    @JsonKey(name: 'location_address') String? locationAddress,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'shop_type') required String shopType,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'instagram_url') String? instagramUrl,
    @JsonKey(name: 'opening_hours') dynamic openingHours,
    @JsonKey(name: 'id_card_url') String? idCardUrl,
    @JsonKey(name: 'storefront_url') String? storefrontUrl,
  }) = _CreateShopRequest;

  factory CreateShopRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShopRequestFromJson(json);
}

// ── Product ───────────────────────────────────────────────────────────────
@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    // API returns field as "title"; we keep "name" for UI compatibility
    @JsonKey(name: 'title') required String name,
    // API returns price as a string (e.g. "50000")
    @_PriceConverter() required double price,
    @Default([]) List<String> images,
    @JsonKey(name: 'stock_quantity') @Default(0) int inStock,
    String? description,
    String? sku,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    // Super App fields — Balla / Matajir distinction
    @JsonKey(name: 'is_balla') @Default(false) bool isBalla,

    /// 'piece' | 'kg' | 'bundle'
    @JsonKey(name: 'sales_unit') @Default('piece') String salesUnit,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
abstract class AddProductRequest with _$AddProductRequest {
  const factory AddProductRequest({
    required String title,
    required int price,
    required String description,
    @JsonKey(name: 'stock_quantity') required int stockQuantity,
    @Default([]) List<String> images,
    String? sku,
  }) = _AddProductRequest;

  factory AddProductRequest.fromJson(Map<String, dynamic> json) =>
      _$AddProductRequestFromJson(json);
}
