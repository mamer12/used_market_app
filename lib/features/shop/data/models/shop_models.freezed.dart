// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopModel {

 String get id; String get name; String get slug; String? get description; String? get category;@JsonKey(name: 'owner_id') String? get ownerId;@JsonKey(name: 'contact_number') String? get contactNumber;@JsonKey(name: 'location_city') String? get locationCity;@JsonKey(name: 'location_district') String? get locationDistrict;@JsonKey(name: 'location_address') String? get locationAddress;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'shop_type') String? get shopType;// 'physical' or 'digital'
@JsonKey(name: 'verification_status') String? get verificationStatus; double? get latitude; double? get longitude;@JsonKey(name: 'instagram_url') String? get instagramUrl;@JsonKey(name: 'opening_hours') dynamic get openingHours;@JsonKey(name: 'id_card_url') String? get idCardUrl;@JsonKey(name: 'storefront_url') String? get storefrontUrl;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopModelCopyWith<ShopModel> get copyWith => _$ShopModelCopyWithImpl<ShopModel>(this as ShopModel, _$identity);

  /// Serializes this ShopModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationDistrict, locationDistrict) || other.locationDistrict == locationDistrict)&&(identical(other.locationAddress, locationAddress) || other.locationAddress == locationAddress)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.shopType, shopType) || other.shopType == shopType)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.idCardUrl, idCardUrl) || other.idCardUrl == idCardUrl)&&(identical(other.storefrontUrl, storefrontUrl) || other.storefrontUrl == storefrontUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,category,ownerId,contactNumber,locationCity,locationDistrict,locationAddress,imageUrl,shopType,verificationStatus,latitude,longitude,instagramUrl,const DeepCollectionEquality().hash(openingHours),idCardUrl,storefrontUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'ShopModel(id: $id, name: $name, slug: $slug, description: $description, category: $category, ownerId: $ownerId, contactNumber: $contactNumber, locationCity: $locationCity, locationDistrict: $locationDistrict, locationAddress: $locationAddress, imageUrl: $imageUrl, shopType: $shopType, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, instagramUrl: $instagramUrl, openingHours: $openingHours, idCardUrl: $idCardUrl, storefrontUrl: $storefrontUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ShopModelCopyWith<$Res>  {
  factory $ShopModelCopyWith(ShopModel value, $Res Function(ShopModel) _then) = _$ShopModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? description, String? category,@JsonKey(name: 'owner_id') String? ownerId,@JsonKey(name: 'contact_number') String? contactNumber,@JsonKey(name: 'location_city') String? locationCity,@JsonKey(name: 'location_district') String? locationDistrict,@JsonKey(name: 'location_address') String? locationAddress,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'shop_type') String? shopType,@JsonKey(name: 'verification_status') String? verificationStatus, double? latitude, double? longitude,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'opening_hours') dynamic openingHours,@JsonKey(name: 'id_card_url') String? idCardUrl,@JsonKey(name: 'storefront_url') String? storefrontUrl,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ShopModelCopyWithImpl<$Res>
    implements $ShopModelCopyWith<$Res> {
  _$ShopModelCopyWithImpl(this._self, this._then);

  final ShopModel _self;
  final $Res Function(ShopModel) _then;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? category = freezed,Object? ownerId = freezed,Object? contactNumber = freezed,Object? locationCity = freezed,Object? locationDistrict = freezed,Object? locationAddress = freezed,Object? imageUrl = freezed,Object? shopType = freezed,Object? verificationStatus = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? instagramUrl = freezed,Object? openingHours = freezed,Object? idCardUrl = freezed,Object? storefrontUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,contactNumber: freezed == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationDistrict: freezed == locationDistrict ? _self.locationDistrict : locationDistrict // ignore: cast_nullable_to_non_nullable
as String?,locationAddress: freezed == locationAddress ? _self.locationAddress : locationAddress // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,shopType: freezed == shopType ? _self.shopType : shopType // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as dynamic,idCardUrl: freezed == idCardUrl ? _self.idCardUrl : idCardUrl // ignore: cast_nullable_to_non_nullable
as String?,storefrontUrl: freezed == storefrontUrl ? _self.storefrontUrl : storefrontUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopModel].
extension ShopModelPatterns on ShopModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopModel value)  $default,){
final _that = this;
switch (_that) {
case _ShopModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? category, @JsonKey(name: 'owner_id')  String? ownerId, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String? shopType, @JsonKey(name: 'verification_status')  String? verificationStatus,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.category,_that.ownerId,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.verificationStatus,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  String? category, @JsonKey(name: 'owner_id')  String? ownerId, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String? shopType, @JsonKey(name: 'verification_status')  String? verificationStatus,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ShopModel():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.category,_that.ownerId,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.verificationStatus,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? description,  String? category, @JsonKey(name: 'owner_id')  String? ownerId, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String? shopType, @JsonKey(name: 'verification_status')  String? verificationStatus,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.category,_that.ownerId,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.verificationStatus,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopModel implements ShopModel {
  const _ShopModel({required this.id, required this.name, required this.slug, this.description, this.category, @JsonKey(name: 'owner_id') this.ownerId, @JsonKey(name: 'contact_number') this.contactNumber, @JsonKey(name: 'location_city') this.locationCity, @JsonKey(name: 'location_district') this.locationDistrict, @JsonKey(name: 'location_address') this.locationAddress, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'shop_type') this.shopType, @JsonKey(name: 'verification_status') this.verificationStatus, this.latitude, this.longitude, @JsonKey(name: 'instagram_url') this.instagramUrl, @JsonKey(name: 'opening_hours') this.openingHours, @JsonKey(name: 'id_card_url') this.idCardUrl, @JsonKey(name: 'storefront_url') this.storefrontUrl, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ShopModel.fromJson(Map<String, dynamic> json) => _$ShopModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'owner_id') final  String? ownerId;
@override@JsonKey(name: 'contact_number') final  String? contactNumber;
@override@JsonKey(name: 'location_city') final  String? locationCity;
@override@JsonKey(name: 'location_district') final  String? locationDistrict;
@override@JsonKey(name: 'location_address') final  String? locationAddress;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'shop_type') final  String? shopType;
// 'physical' or 'digital'
@override@JsonKey(name: 'verification_status') final  String? verificationStatus;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey(name: 'instagram_url') final  String? instagramUrl;
@override@JsonKey(name: 'opening_hours') final  dynamic openingHours;
@override@JsonKey(name: 'id_card_url') final  String? idCardUrl;
@override@JsonKey(name: 'storefront_url') final  String? storefrontUrl;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopModelCopyWith<_ShopModel> get copyWith => __$ShopModelCopyWithImpl<_ShopModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationDistrict, locationDistrict) || other.locationDistrict == locationDistrict)&&(identical(other.locationAddress, locationAddress) || other.locationAddress == locationAddress)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.shopType, shopType) || other.shopType == shopType)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.idCardUrl, idCardUrl) || other.idCardUrl == idCardUrl)&&(identical(other.storefrontUrl, storefrontUrl) || other.storefrontUrl == storefrontUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,category,ownerId,contactNumber,locationCity,locationDistrict,locationAddress,imageUrl,shopType,verificationStatus,latitude,longitude,instagramUrl,const DeepCollectionEquality().hash(openingHours),idCardUrl,storefrontUrl,createdAt,updatedAt]);

@override
String toString() {
  return 'ShopModel(id: $id, name: $name, slug: $slug, description: $description, category: $category, ownerId: $ownerId, contactNumber: $contactNumber, locationCity: $locationCity, locationDistrict: $locationDistrict, locationAddress: $locationAddress, imageUrl: $imageUrl, shopType: $shopType, verificationStatus: $verificationStatus, latitude: $latitude, longitude: $longitude, instagramUrl: $instagramUrl, openingHours: $openingHours, idCardUrl: $idCardUrl, storefrontUrl: $storefrontUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ShopModelCopyWith<$Res> implements $ShopModelCopyWith<$Res> {
  factory _$ShopModelCopyWith(_ShopModel value, $Res Function(_ShopModel) _then) = __$ShopModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? description, String? category,@JsonKey(name: 'owner_id') String? ownerId,@JsonKey(name: 'contact_number') String? contactNumber,@JsonKey(name: 'location_city') String? locationCity,@JsonKey(name: 'location_district') String? locationDistrict,@JsonKey(name: 'location_address') String? locationAddress,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'shop_type') String? shopType,@JsonKey(name: 'verification_status') String? verificationStatus, double? latitude, double? longitude,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'opening_hours') dynamic openingHours,@JsonKey(name: 'id_card_url') String? idCardUrl,@JsonKey(name: 'storefront_url') String? storefrontUrl,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ShopModelCopyWithImpl<$Res>
    implements _$ShopModelCopyWith<$Res> {
  __$ShopModelCopyWithImpl(this._self, this._then);

  final _ShopModel _self;
  final $Res Function(_ShopModel) _then;

/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? category = freezed,Object? ownerId = freezed,Object? contactNumber = freezed,Object? locationCity = freezed,Object? locationDistrict = freezed,Object? locationAddress = freezed,Object? imageUrl = freezed,Object? shopType = freezed,Object? verificationStatus = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? instagramUrl = freezed,Object? openingHours = freezed,Object? idCardUrl = freezed,Object? storefrontUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ShopModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,ownerId: freezed == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String?,contactNumber: freezed == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationDistrict: freezed == locationDistrict ? _self.locationDistrict : locationDistrict // ignore: cast_nullable_to_non_nullable
as String?,locationAddress: freezed == locationAddress ? _self.locationAddress : locationAddress // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,shopType: freezed == shopType ? _self.shopType : shopType // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: freezed == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as dynamic,idCardUrl: freezed == idCardUrl ? _self.idCardUrl : idCardUrl // ignore: cast_nullable_to_non_nullable
as String?,storefrontUrl: freezed == storefrontUrl ? _self.storefrontUrl : storefrontUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateShopRequest {

 String get name; String get slug; String? get description; String? get category;@JsonKey(name: 'contact_number') String? get contactNumber;@JsonKey(name: 'location_city') String? get locationCity;@JsonKey(name: 'location_district') String? get locationDistrict;@JsonKey(name: 'location_address') String? get locationAddress;@JsonKey(name: 'image_url') String? get imageUrl;@JsonKey(name: 'shop_type') String get shopType; double? get latitude; double? get longitude;@JsonKey(name: 'instagram_url') String? get instagramUrl;@JsonKey(name: 'opening_hours') dynamic get openingHours;@JsonKey(name: 'id_card_url') String? get idCardUrl;@JsonKey(name: 'storefront_url') String? get storefrontUrl;
/// Create a copy of CreateShopRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateShopRequestCopyWith<CreateShopRequest> get copyWith => _$CreateShopRequestCopyWithImpl<CreateShopRequest>(this as CreateShopRequest, _$identity);

  /// Serializes this CreateShopRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateShopRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationDistrict, locationDistrict) || other.locationDistrict == locationDistrict)&&(identical(other.locationAddress, locationAddress) || other.locationAddress == locationAddress)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.shopType, shopType) || other.shopType == shopType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.idCardUrl, idCardUrl) || other.idCardUrl == idCardUrl)&&(identical(other.storefrontUrl, storefrontUrl) || other.storefrontUrl == storefrontUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,slug,description,category,contactNumber,locationCity,locationDistrict,locationAddress,imageUrl,shopType,latitude,longitude,instagramUrl,const DeepCollectionEquality().hash(openingHours),idCardUrl,storefrontUrl);

@override
String toString() {
  return 'CreateShopRequest(name: $name, slug: $slug, description: $description, category: $category, contactNumber: $contactNumber, locationCity: $locationCity, locationDistrict: $locationDistrict, locationAddress: $locationAddress, imageUrl: $imageUrl, shopType: $shopType, latitude: $latitude, longitude: $longitude, instagramUrl: $instagramUrl, openingHours: $openingHours, idCardUrl: $idCardUrl, storefrontUrl: $storefrontUrl)';
}


}

/// @nodoc
abstract mixin class $CreateShopRequestCopyWith<$Res>  {
  factory $CreateShopRequestCopyWith(CreateShopRequest value, $Res Function(CreateShopRequest) _then) = _$CreateShopRequestCopyWithImpl;
@useResult
$Res call({
 String name, String slug, String? description, String? category,@JsonKey(name: 'contact_number') String? contactNumber,@JsonKey(name: 'location_city') String? locationCity,@JsonKey(name: 'location_district') String? locationDistrict,@JsonKey(name: 'location_address') String? locationAddress,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'shop_type') String shopType, double? latitude, double? longitude,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'opening_hours') dynamic openingHours,@JsonKey(name: 'id_card_url') String? idCardUrl,@JsonKey(name: 'storefront_url') String? storefrontUrl
});




}
/// @nodoc
class _$CreateShopRequestCopyWithImpl<$Res>
    implements $CreateShopRequestCopyWith<$Res> {
  _$CreateShopRequestCopyWithImpl(this._self, this._then);

  final CreateShopRequest _self;
  final $Res Function(CreateShopRequest) _then;

/// Create a copy of CreateShopRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? slug = null,Object? description = freezed,Object? category = freezed,Object? contactNumber = freezed,Object? locationCity = freezed,Object? locationDistrict = freezed,Object? locationAddress = freezed,Object? imageUrl = freezed,Object? shopType = null,Object? latitude = freezed,Object? longitude = freezed,Object? instagramUrl = freezed,Object? openingHours = freezed,Object? idCardUrl = freezed,Object? storefrontUrl = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,contactNumber: freezed == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationDistrict: freezed == locationDistrict ? _self.locationDistrict : locationDistrict // ignore: cast_nullable_to_non_nullable
as String?,locationAddress: freezed == locationAddress ? _self.locationAddress : locationAddress // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,shopType: null == shopType ? _self.shopType : shopType // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as dynamic,idCardUrl: freezed == idCardUrl ? _self.idCardUrl : idCardUrl // ignore: cast_nullable_to_non_nullable
as String?,storefrontUrl: freezed == storefrontUrl ? _self.storefrontUrl : storefrontUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateShopRequest].
extension CreateShopRequestPatterns on CreateShopRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateShopRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateShopRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateShopRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateShopRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String slug,  String? description,  String? category, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String shopType,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that.name,_that.slug,_that.description,_that.category,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String slug,  String? description,  String? category, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String shopType,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl)  $default,) {final _that = this;
switch (_that) {
case _CreateShopRequest():
return $default(_that.name,_that.slug,_that.description,_that.category,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String slug,  String? description,  String? category, @JsonKey(name: 'contact_number')  String? contactNumber, @JsonKey(name: 'location_city')  String? locationCity, @JsonKey(name: 'location_district')  String? locationDistrict, @JsonKey(name: 'location_address')  String? locationAddress, @JsonKey(name: 'image_url')  String? imageUrl, @JsonKey(name: 'shop_type')  String shopType,  double? latitude,  double? longitude, @JsonKey(name: 'instagram_url')  String? instagramUrl, @JsonKey(name: 'opening_hours')  dynamic openingHours, @JsonKey(name: 'id_card_url')  String? idCardUrl, @JsonKey(name: 'storefront_url')  String? storefrontUrl)?  $default,) {final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that.name,_that.slug,_that.description,_that.category,_that.contactNumber,_that.locationCity,_that.locationDistrict,_that.locationAddress,_that.imageUrl,_that.shopType,_that.latitude,_that.longitude,_that.instagramUrl,_that.openingHours,_that.idCardUrl,_that.storefrontUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateShopRequest implements CreateShopRequest {
  const _CreateShopRequest({required this.name, required this.slug, this.description, this.category, @JsonKey(name: 'contact_number') this.contactNumber, @JsonKey(name: 'location_city') this.locationCity, @JsonKey(name: 'location_district') this.locationDistrict, @JsonKey(name: 'location_address') this.locationAddress, @JsonKey(name: 'image_url') this.imageUrl, @JsonKey(name: 'shop_type') required this.shopType, this.latitude, this.longitude, @JsonKey(name: 'instagram_url') this.instagramUrl, @JsonKey(name: 'opening_hours') this.openingHours, @JsonKey(name: 'id_card_url') this.idCardUrl, @JsonKey(name: 'storefront_url') this.storefrontUrl});
  factory _CreateShopRequest.fromJson(Map<String, dynamic> json) => _$CreateShopRequestFromJson(json);

@override final  String name;
@override final  String slug;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'contact_number') final  String? contactNumber;
@override@JsonKey(name: 'location_city') final  String? locationCity;
@override@JsonKey(name: 'location_district') final  String? locationDistrict;
@override@JsonKey(name: 'location_address') final  String? locationAddress;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey(name: 'shop_type') final  String shopType;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey(name: 'instagram_url') final  String? instagramUrl;
@override@JsonKey(name: 'opening_hours') final  dynamic openingHours;
@override@JsonKey(name: 'id_card_url') final  String? idCardUrl;
@override@JsonKey(name: 'storefront_url') final  String? storefrontUrl;

/// Create a copy of CreateShopRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateShopRequestCopyWith<_CreateShopRequest> get copyWith => __$CreateShopRequestCopyWithImpl<_CreateShopRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateShopRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateShopRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationDistrict, locationDistrict) || other.locationDistrict == locationDistrict)&&(identical(other.locationAddress, locationAddress) || other.locationAddress == locationAddress)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.shopType, shopType) || other.shopType == shopType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.instagramUrl, instagramUrl) || other.instagramUrl == instagramUrl)&&const DeepCollectionEquality().equals(other.openingHours, openingHours)&&(identical(other.idCardUrl, idCardUrl) || other.idCardUrl == idCardUrl)&&(identical(other.storefrontUrl, storefrontUrl) || other.storefrontUrl == storefrontUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,slug,description,category,contactNumber,locationCity,locationDistrict,locationAddress,imageUrl,shopType,latitude,longitude,instagramUrl,const DeepCollectionEquality().hash(openingHours),idCardUrl,storefrontUrl);

@override
String toString() {
  return 'CreateShopRequest(name: $name, slug: $slug, description: $description, category: $category, contactNumber: $contactNumber, locationCity: $locationCity, locationDistrict: $locationDistrict, locationAddress: $locationAddress, imageUrl: $imageUrl, shopType: $shopType, latitude: $latitude, longitude: $longitude, instagramUrl: $instagramUrl, openingHours: $openingHours, idCardUrl: $idCardUrl, storefrontUrl: $storefrontUrl)';
}


}

/// @nodoc
abstract mixin class _$CreateShopRequestCopyWith<$Res> implements $CreateShopRequestCopyWith<$Res> {
  factory _$CreateShopRequestCopyWith(_CreateShopRequest value, $Res Function(_CreateShopRequest) _then) = __$CreateShopRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String slug, String? description, String? category,@JsonKey(name: 'contact_number') String? contactNumber,@JsonKey(name: 'location_city') String? locationCity,@JsonKey(name: 'location_district') String? locationDistrict,@JsonKey(name: 'location_address') String? locationAddress,@JsonKey(name: 'image_url') String? imageUrl,@JsonKey(name: 'shop_type') String shopType, double? latitude, double? longitude,@JsonKey(name: 'instagram_url') String? instagramUrl,@JsonKey(name: 'opening_hours') dynamic openingHours,@JsonKey(name: 'id_card_url') String? idCardUrl,@JsonKey(name: 'storefront_url') String? storefrontUrl
});




}
/// @nodoc
class __$CreateShopRequestCopyWithImpl<$Res>
    implements _$CreateShopRequestCopyWith<$Res> {
  __$CreateShopRequestCopyWithImpl(this._self, this._then);

  final _CreateShopRequest _self;
  final $Res Function(_CreateShopRequest) _then;

/// Create a copy of CreateShopRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? slug = null,Object? description = freezed,Object? category = freezed,Object? contactNumber = freezed,Object? locationCity = freezed,Object? locationDistrict = freezed,Object? locationAddress = freezed,Object? imageUrl = freezed,Object? shopType = null,Object? latitude = freezed,Object? longitude = freezed,Object? instagramUrl = freezed,Object? openingHours = freezed,Object? idCardUrl = freezed,Object? storefrontUrl = freezed,}) {
  return _then(_CreateShopRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,contactNumber: freezed == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationDistrict: freezed == locationDistrict ? _self.locationDistrict : locationDistrict // ignore: cast_nullable_to_non_nullable
as String?,locationAddress: freezed == locationAddress ? _self.locationAddress : locationAddress // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,shopType: null == shopType ? _self.shopType : shopType // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,instagramUrl: freezed == instagramUrl ? _self.instagramUrl : instagramUrl // ignore: cast_nullable_to_non_nullable
as String?,openingHours: freezed == openingHours ? _self.openingHours : openingHours // ignore: cast_nullable_to_non_nullable
as dynamic,idCardUrl: freezed == idCardUrl ? _self.idCardUrl : idCardUrl // ignore: cast_nullable_to_non_nullable
as String?,storefrontUrl: freezed == storefrontUrl ? _self.storefrontUrl : storefrontUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId;// API returns field as "title"; we keep "name" for UI compatibility
@JsonKey(name: 'title') String get name;// API returns price as a string (e.g. "50000")
@_PriceConverter() double get price; List<String> get images;@JsonKey(name: 'stock_quantity') int get inStock; String? get description; String? get sku;@JsonKey(name: 'is_active') bool get isActive;// Super App fields — Balla / Matajir distinction
@JsonKey(name: 'is_balla') bool get isBalla;/// 'piece' | 'kg' | 'bundle'
@JsonKey(name: 'sales_unit') String get salesUnit;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelCopyWith<ProductModel> get copyWith => _$ProductModelCopyWithImpl<ProductModel>(this as ProductModel, _$identity);

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.description, description) || other.description == description)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isBalla, isBalla) || other.isBalla == isBalla)&&(identical(other.salesUnit, salesUnit) || other.salesUnit == salesUnit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,price,const DeepCollectionEquality().hash(images),inStock,description,sku,isActive,isBalla,salesUnit,createdAt,updatedAt);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, name: $name, price: $price, images: $images, inStock: $inStock, description: $description, sku: $sku, isActive: $isActive, isBalla: $isBalla, salesUnit: $salesUnit, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProductModelCopyWith<$Res>  {
  factory $ProductModelCopyWith(ProductModel value, $Res Function(ProductModel) _then) = _$ProductModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'title') String name,@_PriceConverter() double price, List<String> images,@JsonKey(name: 'stock_quantity') int inStock, String? description, String? sku,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_balla') bool isBalla,@JsonKey(name: 'sales_unit') String salesUnit,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ProductModelCopyWithImpl<$Res>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._self, this._then);

  final ProductModel _self;
  final $Res Function(ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,Object? description = freezed,Object? sku = freezed,Object? isActive = null,Object? isBalla = null,Object? salesUnit = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isBalla: null == isBalla ? _self.isBalla : isBalla // ignore: cast_nullable_to_non_nullable
as bool,salesUnit: null == salesUnit ? _self.salesUnit : salesUnit // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductModel].
extension ProductModelPatterns on ProductModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductModel value)  $default,){
final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'title')  String name, @_PriceConverter()  double price,  List<String> images, @JsonKey(name: 'stock_quantity')  int inStock,  String? description,  String? sku, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_balla')  bool isBalla, @JsonKey(name: 'sales_unit')  String salesUnit, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock,_that.description,_that.sku,_that.isActive,_that.isBalla,_that.salesUnit,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'title')  String name, @_PriceConverter()  double price,  List<String> images, @JsonKey(name: 'stock_quantity')  int inStock,  String? description,  String? sku, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_balla')  bool isBalla, @JsonKey(name: 'sales_unit')  String salesUnit, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock,_that.description,_that.sku,_that.isActive,_that.isBalla,_that.salesUnit,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId, @JsonKey(name: 'title')  String name, @_PriceConverter()  double price,  List<String> images, @JsonKey(name: 'stock_quantity')  int inStock,  String? description,  String? sku, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_balla')  bool isBalla, @JsonKey(name: 'sales_unit')  String salesUnit, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock,_that.description,_that.sku,_that.isActive,_that.isBalla,_that.salesUnit,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel implements ProductModel {
  const _ProductModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, @JsonKey(name: 'title') required this.name, @_PriceConverter() required this.price, final  List<String> images = const [], @JsonKey(name: 'stock_quantity') this.inStock = 0, this.description, this.sku, @JsonKey(name: 'is_active') this.isActive = true, @JsonKey(name: 'is_balla') this.isBalla = false, @JsonKey(name: 'sales_unit') this.salesUnit = 'piece', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _images = images;
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
// API returns field as "title"; we keep "name" for UI compatibility
@override@JsonKey(name: 'title') final  String name;
// API returns price as a string (e.g. "50000")
@override@_PriceConverter() final  double price;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'stock_quantity') final  int inStock;
@override final  String? description;
@override final  String? sku;
@override@JsonKey(name: 'is_active') final  bool isActive;
// Super App fields — Balla / Matajir distinction
@override@JsonKey(name: 'is_balla') final  bool isBalla;
/// 'piece' | 'kg' | 'bundle'
@override@JsonKey(name: 'sales_unit') final  String salesUnit;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductModelCopyWith<_ProductModel> get copyWith => __$ProductModelCopyWithImpl<_ProductModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.inStock, inStock) || other.inStock == inStock)&&(identical(other.description, description) || other.description == description)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isBalla, isBalla) || other.isBalla == isBalla)&&(identical(other.salesUnit, salesUnit) || other.salesUnit == salesUnit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,price,const DeepCollectionEquality().hash(_images),inStock,description,sku,isActive,isBalla,salesUnit,createdAt,updatedAt);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, name: $name, price: $price, images: $images, inStock: $inStock, description: $description, sku: $sku, isActive: $isActive, isBalla: $isBalla, salesUnit: $salesUnit, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProductModelCopyWith<$Res> implements $ProductModelCopyWith<$Res> {
  factory _$ProductModelCopyWith(_ProductModel value, $Res Function(_ProductModel) _then) = __$ProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId,@JsonKey(name: 'title') String name,@_PriceConverter() double price, List<String> images,@JsonKey(name: 'stock_quantity') int inStock, String? description, String? sku,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_balla') bool isBalla,@JsonKey(name: 'sales_unit') String salesUnit,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ProductModelCopyWithImpl<$Res>
    implements _$ProductModelCopyWith<$Res> {
  __$ProductModelCopyWithImpl(this._self, this._then);

  final _ProductModel _self;
  final $Res Function(_ProductModel) _then;

/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,Object? description = freezed,Object? sku = freezed,Object? isActive = null,Object? isBalla = null,Object? salesUnit = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isBalla: null == isBalla ? _self.isBalla : isBalla // ignore: cast_nullable_to_non_nullable
as bool,salesUnit: null == salesUnit ? _self.salesUnit : salesUnit // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AddProductRequest {

 String get title; int get price; String get description;@JsonKey(name: 'stock_quantity') int get stockQuantity; List<String> get images; String? get sku;
/// Create a copy of AddProductRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddProductRequestCopyWith<AddProductRequest> get copyWith => _$AddProductRequestCopyWithImpl<AddProductRequest>(this as AddProductRequest, _$identity);

  /// Serializes this AddProductRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddProductRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,price,description,stockQuantity,const DeepCollectionEquality().hash(images),sku);

@override
String toString() {
  return 'AddProductRequest(title: $title, price: $price, description: $description, stockQuantity: $stockQuantity, images: $images, sku: $sku)';
}


}

/// @nodoc
abstract mixin class $AddProductRequestCopyWith<$Res>  {
  factory $AddProductRequestCopyWith(AddProductRequest value, $Res Function(AddProductRequest) _then) = _$AddProductRequestCopyWithImpl;
@useResult
$Res call({
 String title, int price, String description,@JsonKey(name: 'stock_quantity') int stockQuantity, List<String> images, String? sku
});




}
/// @nodoc
class _$AddProductRequestCopyWithImpl<$Res>
    implements $AddProductRequestCopyWith<$Res> {
  _$AddProductRequestCopyWithImpl(this._self, this._then);

  final AddProductRequest _self;
  final $Res Function(AddProductRequest) _then;

/// Create a copy of AddProductRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? price = null,Object? description = null,Object? stockQuantity = null,Object? images = null,Object? sku = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AddProductRequest].
extension AddProductRequestPatterns on AddProductRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddProductRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddProductRequest value)  $default,){
final _that = this;
switch (_that) {
case _AddProductRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddProductRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  int price,  String description, @JsonKey(name: 'stock_quantity')  int stockQuantity,  List<String> images,  String? sku)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that.title,_that.price,_that.description,_that.stockQuantity,_that.images,_that.sku);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  int price,  String description, @JsonKey(name: 'stock_quantity')  int stockQuantity,  List<String> images,  String? sku)  $default,) {final _that = this;
switch (_that) {
case _AddProductRequest():
return $default(_that.title,_that.price,_that.description,_that.stockQuantity,_that.images,_that.sku);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  int price,  String description, @JsonKey(name: 'stock_quantity')  int stockQuantity,  List<String> images,  String? sku)?  $default,) {final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that.title,_that.price,_that.description,_that.stockQuantity,_that.images,_that.sku);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddProductRequest implements AddProductRequest {
  const _AddProductRequest({required this.title, required this.price, required this.description, @JsonKey(name: 'stock_quantity') required this.stockQuantity, final  List<String> images = const [], this.sku}): _images = images;
  factory _AddProductRequest.fromJson(Map<String, dynamic> json) => _$AddProductRequestFromJson(json);

@override final  String title;
@override final  int price;
@override final  String description;
@override@JsonKey(name: 'stock_quantity') final  int stockQuantity;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? sku;

/// Create a copy of AddProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddProductRequestCopyWith<_AddProductRequest> get copyWith => __$AddProductRequestCopyWithImpl<_AddProductRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddProductRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddProductRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,price,description,stockQuantity,const DeepCollectionEquality().hash(_images),sku);

@override
String toString() {
  return 'AddProductRequest(title: $title, price: $price, description: $description, stockQuantity: $stockQuantity, images: $images, sku: $sku)';
}


}

/// @nodoc
abstract mixin class _$AddProductRequestCopyWith<$Res> implements $AddProductRequestCopyWith<$Res> {
  factory _$AddProductRequestCopyWith(_AddProductRequest value, $Res Function(_AddProductRequest) _then) = __$AddProductRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, int price, String description,@JsonKey(name: 'stock_quantity') int stockQuantity, List<String> images, String? sku
});




}
/// @nodoc
class __$AddProductRequestCopyWithImpl<$Res>
    implements _$AddProductRequestCopyWith<$Res> {
  __$AddProductRequestCopyWithImpl(this._self, this._then);

  final _AddProductRequest _self;
  final $Res Function(_AddProductRequest) _then;

/// Create a copy of AddProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? price = null,Object? description = null,Object? stockQuantity = null,Object? images = null,Object? sku = freezed,}) {
  return _then(_AddProductRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
