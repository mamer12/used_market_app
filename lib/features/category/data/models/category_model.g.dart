// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    _CategoryModel(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
      slug: json['slug'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      iconUrl: json['icon_url'] as String?,
      level: (json['level'] as num).toInt(),
      supportedApps: (json['supported_apps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$CategoryModelToJson(_CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'slug': instance.slug,
      'name_ar': instance.nameAr,
      'name_en': instance.nameEn,
      'icon_url': instance.iconUrl,
      'level': instance.level,
      'supported_apps': instance.supportedApps,
      'is_active': instance.isActive,
    };
