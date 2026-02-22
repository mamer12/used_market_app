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
  category: json['category'] as String?,
  ownerId: json['owner_id'] as String?,
  contactNumber: json['contact_number'] as String?,
  locationCity: json['location_city'] as String?,
  locationDistrict: json['location_district'] as String?,
  locationAddress: json['location_address'] as String?,
  imageUrl: json['image_url'] as String?,
  shopType: json['shop_type'] as String?,
  verificationStatus: json['verification_status'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  instagramUrl: json['instagram_url'] as String?,
  openingHours: json['opening_hours'],
  idCardUrl: json['id_card_url'] as String?,
  storefrontUrl: json['storefront_url'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ShopModelToJson(_ShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category': instance.category,
      'owner_id': instance.ownerId,
      'contact_number': instance.contactNumber,
      'location_city': instance.locationCity,
      'location_district': instance.locationDistrict,
      'location_address': instance.locationAddress,
      'image_url': instance.imageUrl,
      'shop_type': instance.shopType,
      'verification_status': instance.verificationStatus,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instagram_url': instance.instagramUrl,
      'opening_hours': instance.openingHours,
      'id_card_url': instance.idCardUrl,
      'storefront_url': instance.storefrontUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_CreateShopRequest _$CreateShopRequestFromJson(Map<String, dynamic> json) =>
    _CreateShopRequest(
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      contactNumber: json['contact_number'] as String?,
      locationCity: json['location_city'] as String?,
      locationDistrict: json['location_district'] as String?,
      locationAddress: json['location_address'] as String?,
      imageUrl: json['image_url'] as String?,
      shopType: json['shop_type'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      instagramUrl: json['instagram_url'] as String?,
      openingHours: json['opening_hours'],
      idCardUrl: json['id_card_url'] as String?,
      storefrontUrl: json['storefront_url'] as String?,
    );

Map<String, dynamic> _$CreateShopRequestToJson(_CreateShopRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'category': instance.category,
      'contact_number': instance.contactNumber,
      'location_city': instance.locationCity,
      'location_district': instance.locationDistrict,
      'location_address': instance.locationAddress,
      'image_url': instance.imageUrl,
      'shop_type': instance.shopType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instagram_url': instance.instagramUrl,
      'opening_hours': instance.openingHours,
      'id_card_url': instance.idCardUrl,
      'storefront_url': instance.storefrontUrl,
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
