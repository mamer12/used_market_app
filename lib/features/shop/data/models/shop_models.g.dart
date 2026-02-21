// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => _ShopModel(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  coverImage: json['cover_image'] as String?,
);

Map<String, dynamic> _$ShopModelToJson(_ShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'cover_image': instance.coverImage,
    };

_CreateShopRequest _$CreateShopRequestFromJson(Map<String, dynamic> json) =>
    _CreateShopRequest(
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
    );

Map<String, dynamic> _$CreateShopRequestToJson(_CreateShopRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'cover_image': instance.coverImage,
    };

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      inStock: (json['in_stock'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'name': instance.name,
      'price': instance.price,
      'images': instance.images,
      'in_stock': instance.inStock,
    };

_AddProductRequest _$AddProductRequestFromJson(Map<String, dynamic> json) =>
    _AddProductRequest(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      inStock: (json['in_stock'] as num).toInt(),
    );

Map<String, dynamic> _$AddProductRequestToJson(_AddProductRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'images': instance.images,
      'in_stock': instance.inStock,
    };
