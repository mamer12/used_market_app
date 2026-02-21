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
  ownerId: json['owner_id'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ShopModelToJson(_ShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'owner_id': instance.ownerId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_CreateShopRequest _$CreateShopRequestFromJson(Map<String, dynamic> json) =>
    _CreateShopRequest(
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateShopRequestToJson(_CreateShopRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
    };

_ProductModel _$ProductModelFromJson(Map<String, dynamic> json) =>
    _ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['title'] as String,
      price: const _PriceConverter().fromJson(json['price'] as Object),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      inStock: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$ProductModelToJson(_ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shop_id': instance.shopId,
      'title': instance.name,
      'price': const _PriceConverter().toJson(instance.price),
      'images': instance.images,
      'stock_quantity': instance.inStock,
      'description': instance.description,
      'sku': instance.sku,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_AddProductRequest _$AddProductRequestFromJson(Map<String, dynamic> json) =>
    _AddProductRequest(
      title: json['title'] as String,
      price: (json['price'] as num).toInt(),
      description: json['description'] as String,
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sku: json['sku'] as String?,
    );

Map<String, dynamic> _$AddProductRequestToJson(_AddProductRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'price': instance.price,
      'description': instance.description,
      'stock_quantity': instance.stockQuantity,
      'images': instance.images,
      'sku': instance.sku,
    };
