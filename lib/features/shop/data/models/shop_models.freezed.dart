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

 String get id; String get name; String get slug; String? get description;@JsonKey(name: 'cover_image') String? get coverImage;
/// Create a copy of ShopModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopModelCopyWith<ShopModel> get copyWith => _$ShopModelCopyWithImpl<ShopModel>(this as ShopModel, _$identity);

  /// Serializes this ShopModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,coverImage);

@override
String toString() {
  return 'ShopModel(id: $id, name: $name, slug: $slug, description: $description, coverImage: $coverImage)';
}


}

/// @nodoc
abstract mixin class $ShopModelCopyWith<$Res>  {
  factory $ShopModelCopyWith(ShopModel value, $Res Function(ShopModel) _then) = _$ShopModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? description,@JsonKey(name: 'cover_image') String? coverImage
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? coverImage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.coverImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)  $default,) {final _that = this;
switch (_that) {
case _ShopModel():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.coverImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)?  $default,) {final _that = this;
switch (_that) {
case _ShopModel() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.coverImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopModel implements ShopModel {
  const _ShopModel({required this.id, required this.name, required this.slug, this.description, @JsonKey(name: 'cover_image') this.coverImage});
  factory _ShopModel.fromJson(Map<String, dynamic> json) => _$ShopModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? description;
@override@JsonKey(name: 'cover_image') final  String? coverImage;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,description,coverImage);

@override
String toString() {
  return 'ShopModel(id: $id, name: $name, slug: $slug, description: $description, coverImage: $coverImage)';
}


}

/// @nodoc
abstract mixin class _$ShopModelCopyWith<$Res> implements $ShopModelCopyWith<$Res> {
  factory _$ShopModelCopyWith(_ShopModel value, $Res Function(_ShopModel) _then) = __$ShopModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? description,@JsonKey(name: 'cover_image') String? coverImage
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? coverImage = freezed,}) {
  return _then(_ShopModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateShopRequest {

 String get name; String get slug; String? get description;@JsonKey(name: 'cover_image') String? get coverImage;
/// Create a copy of CreateShopRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateShopRequestCopyWith<CreateShopRequest> get copyWith => _$CreateShopRequestCopyWithImpl<CreateShopRequest>(this as CreateShopRequest, _$identity);

  /// Serializes this CreateShopRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateShopRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,slug,description,coverImage);

@override
String toString() {
  return 'CreateShopRequest(name: $name, slug: $slug, description: $description, coverImage: $coverImage)';
}


}

/// @nodoc
abstract mixin class $CreateShopRequestCopyWith<$Res>  {
  factory $CreateShopRequestCopyWith(CreateShopRequest value, $Res Function(CreateShopRequest) _then) = _$CreateShopRequestCopyWithImpl;
@useResult
$Res call({
 String name, String slug, String? description,@JsonKey(name: 'cover_image') String? coverImage
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? slug = null,Object? description = freezed,Object? coverImage = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that.name,_that.slug,_that.description,_that.coverImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)  $default,) {final _that = this;
switch (_that) {
case _CreateShopRequest():
return $default(_that.name,_that.slug,_that.description,_that.coverImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String slug,  String? description, @JsonKey(name: 'cover_image')  String? coverImage)?  $default,) {final _that = this;
switch (_that) {
case _CreateShopRequest() when $default != null:
return $default(_that.name,_that.slug,_that.description,_that.coverImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateShopRequest implements CreateShopRequest {
  const _CreateShopRequest({required this.name, required this.slug, this.description, @JsonKey(name: 'cover_image') this.coverImage});
  factory _CreateShopRequest.fromJson(Map<String, dynamic> json) => _$CreateShopRequestFromJson(json);

@override final  String name;
@override final  String slug;
@override final  String? description;
@override@JsonKey(name: 'cover_image') final  String? coverImage;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateShopRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,slug,description,coverImage);

@override
String toString() {
  return 'CreateShopRequest(name: $name, slug: $slug, description: $description, coverImage: $coverImage)';
}


}

/// @nodoc
abstract mixin class _$CreateShopRequestCopyWith<$Res> implements $CreateShopRequestCopyWith<$Res> {
  factory _$CreateShopRequestCopyWith(_CreateShopRequest value, $Res Function(_CreateShopRequest) _then) = __$CreateShopRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String slug, String? description,@JsonKey(name: 'cover_image') String? coverImage
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? slug = null,Object? description = freezed,Object? coverImage = freezed,}) {
  return _then(_CreateShopRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ProductModel {

 String get id;@JsonKey(name: 'shop_id') String get shopId; String get name; double get price; List<String> get images;@JsonKey(name: 'in_stock') int get inStock;
/// Create a copy of ProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductModelCopyWith<ProductModel> get copyWith => _$ProductModelCopyWithImpl<ProductModel>(this as ProductModel, _$identity);

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.inStock, inStock) || other.inStock == inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,price,const DeepCollectionEquality().hash(images),inStock);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, name: $name, price: $price, images: $images, inStock: $inStock)';
}


}

/// @nodoc
abstract mixin class $ProductModelCopyWith<$Res>  {
  factory $ProductModelCopyWith(ProductModel value, $Res Function(ProductModel) _then) = _$ProductModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String name, double price, List<String> images,@JsonKey(name: 'in_stock') int inStock
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)  $default,) {final _that = this;
switch (_that) {
case _ProductModel():
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'shop_id')  String shopId,  String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)?  $default,) {final _that = this;
switch (_that) {
case _ProductModel() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.price,_that.images,_that.inStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductModel implements ProductModel {
  const _ProductModel({required this.id, @JsonKey(name: 'shop_id') required this.shopId, required this.name, required this.price, final  List<String> images = const [], @JsonKey(name: 'in_stock') this.inStock = 0}): _images = images;
  factory _ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'shop_id') final  String shopId;
@override final  String name;
@override final  double price;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'in_stock') final  int inStock;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductModel&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.inStock, inStock) || other.inStock == inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,price,const DeepCollectionEquality().hash(_images),inStock);

@override
String toString() {
  return 'ProductModel(id: $id, shopId: $shopId, name: $name, price: $price, images: $images, inStock: $inStock)';
}


}

/// @nodoc
abstract mixin class _$ProductModelCopyWith<$Res> implements $ProductModelCopyWith<$Res> {
  factory _$ProductModelCopyWith(_ProductModel value, $Res Function(_ProductModel) _then) = __$ProductModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'shop_id') String shopId, String name, double price, List<String> images,@JsonKey(name: 'in_stock') int inStock
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,}) {
  return _then(_ProductModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AddProductRequest {

 String get name; double get price; List<String> get images;@JsonKey(name: 'in_stock') int get inStock;
/// Create a copy of AddProductRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddProductRequestCopyWith<AddProductRequest> get copyWith => _$AddProductRequestCopyWithImpl<AddProductRequest>(this as AddProductRequest, _$identity);

  /// Serializes this AddProductRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddProductRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.inStock, inStock) || other.inStock == inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,const DeepCollectionEquality().hash(images),inStock);

@override
String toString() {
  return 'AddProductRequest(name: $name, price: $price, images: $images, inStock: $inStock)';
}


}

/// @nodoc
abstract mixin class $AddProductRequestCopyWith<$Res>  {
  factory $AddProductRequestCopyWith(AddProductRequest value, $Res Function(AddProductRequest) _then) = _$AddProductRequestCopyWithImpl;
@useResult
$Res call({
 String name, double price, List<String> images,@JsonKey(name: 'in_stock') int inStock
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that.name,_that.price,_that.images,_that.inStock);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)  $default,) {final _that = this;
switch (_that) {
case _AddProductRequest():
return $default(_that.name,_that.price,_that.images,_that.inStock);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  List<String> images, @JsonKey(name: 'in_stock')  int inStock)?  $default,) {final _that = this;
switch (_that) {
case _AddProductRequest() when $default != null:
return $default(_that.name,_that.price,_that.images,_that.inStock);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddProductRequest implements AddProductRequest {
  const _AddProductRequest({required this.name, required this.price, required final  List<String> images, @JsonKey(name: 'in_stock') required this.inStock}): _images = images;
  factory _AddProductRequest.fromJson(Map<String, dynamic> json) => _$AddProductRequestFromJson(json);

@override final  String name;
@override final  double price;
 final  List<String> _images;
@override List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'in_stock') final  int inStock;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddProductRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.inStock, inStock) || other.inStock == inStock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,const DeepCollectionEquality().hash(_images),inStock);

@override
String toString() {
  return 'AddProductRequest(name: $name, price: $price, images: $images, inStock: $inStock)';
}


}

/// @nodoc
abstract mixin class _$AddProductRequestCopyWith<$Res> implements $AddProductRequestCopyWith<$Res> {
  factory _$AddProductRequestCopyWith(_AddProductRequest value, $Res Function(_AddProductRequest) _then) = __$AddProductRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, List<String> images,@JsonKey(name: 'in_stock') int inStock
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? images = null,Object? inStock = null,}) {
  return _then(_AddProductRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,inStock: null == inStock ? _self.inStock : inStock // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
