import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_models.freezed.dart';
part 'shop_models.g.dart';

@freezed
abstract class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    @JsonKey(name: 'cover_image') String? coverImage,
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
    @JsonKey(name: 'cover_image') String? coverImage,
  }) = _CreateShopRequest;

  factory CreateShopRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShopRequestFromJson(json);
}

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    @JsonKey(name: 'shop_id') required String shopId,
    required String name,
    required double price,
    @Default([]) List<String> images,
    @JsonKey(name: 'in_stock') @Default(0) int inStock,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
abstract class AddProductRequest with _$AddProductRequest {
  const factory AddProductRequest({
    required String name,
    required double price,
    required List<String> images,
    @JsonKey(name: 'in_stock') required int inStock,
  }) = _AddProductRequest;

  factory AddProductRequest.fromJson(Map<String, dynamic> json) =>
      _$AddProductRequestFromJson(json);
}
