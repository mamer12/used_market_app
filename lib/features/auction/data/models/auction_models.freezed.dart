// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auction_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuctionItemModel {

 String get title; String get description; String? get category; String? get condition; String? get city; List<String> get images;
/// Create a copy of AuctionItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionItemModelCopyWith<AuctionItemModel> get copyWith => _$AuctionItemModelCopyWithImpl<AuctionItemModel>(this as AuctionItemModel, _$identity);

  /// Serializes this AuctionItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionItemModel&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,condition,city,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'AuctionItemModel(title: $title, description: $description, category: $category, condition: $condition, city: $city, images: $images)';
}


}

/// @nodoc
abstract mixin class $AuctionItemModelCopyWith<$Res>  {
  factory $AuctionItemModelCopyWith(AuctionItemModel value, $Res Function(AuctionItemModel) _then) = _$AuctionItemModelCopyWithImpl;
@useResult
$Res call({
 String title, String description, String? category, String? condition, String? city, List<String> images
});




}
/// @nodoc
class _$AuctionItemModelCopyWithImpl<$Res>
    implements $AuctionItemModelCopyWith<$Res> {
  _$AuctionItemModelCopyWithImpl(this._self, this._then);

  final AuctionItemModel _self;
  final $Res Function(AuctionItemModel) _then;

/// Create a copy of AuctionItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? category = freezed,Object? condition = freezed,Object? city = freezed,Object? images = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuctionItemModel].
extension AuctionItemModelPatterns on AuctionItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionItemModel value)  $default,){
final _that = this;
switch (_that) {
case _AuctionItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String? category,  String? condition,  String? city,  List<String> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionItemModel() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String? category,  String? condition,  String? city,  List<String> images)  $default,) {final _that = this;
switch (_that) {
case _AuctionItemModel():
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String? category,  String? condition,  String? city,  List<String> images)?  $default,) {final _that = this;
switch (_that) {
case _AuctionItemModel() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionItemModel implements AuctionItemModel {
  const _AuctionItemModel({this.title = '', this.description = '', this.category, this.condition, this.city, final  List<String> images = const []}): _images = images;
  factory _AuctionItemModel.fromJson(Map<String, dynamic> json) => _$AuctionItemModelFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  String? category;
@override final  String? condition;
@override final  String? city;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of AuctionItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionItemModelCopyWith<_AuctionItemModel> get copyWith => __$AuctionItemModelCopyWithImpl<_AuctionItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionItemModel&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,condition,city,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'AuctionItemModel(title: $title, description: $description, category: $category, condition: $condition, city: $city, images: $images)';
}


}

/// @nodoc
abstract mixin class _$AuctionItemModelCopyWith<$Res> implements $AuctionItemModelCopyWith<$Res> {
  factory _$AuctionItemModelCopyWith(_AuctionItemModel value, $Res Function(_AuctionItemModel) _then) = __$AuctionItemModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String? category, String? condition, String? city, List<String> images
});




}
/// @nodoc
class __$AuctionItemModelCopyWithImpl<$Res>
    implements _$AuctionItemModelCopyWith<$Res> {
  __$AuctionItemModelCopyWithImpl(this._self, this._then);

  final _AuctionItemModel _self;
  final $Res Function(_AuctionItemModel) _then;

/// Create a copy of AuctionItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? category = freezed,Object? condition = freezed,Object? city = freezed,Object? images = null,}) {
  return _then(_AuctionItemModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$AuctionModel {

 String? get id;@JsonKey(name: 'item_id') String? get itemId;// Flattened from nested `item` object via custom fromJson below.
 String get title; String get description; String? get category; String? get condition; String? get city; List<String> get images;// Monetary fields — API sends as strings.
@JsonKey(name: 'start_price')@_MoneyConverter() int? get startPrice;@JsonKey(name: 'current_price')@_MoneyConverter() int? get currentPrice;@JsonKey(name: 'min_bid_increment')@_MoneyConverter() int? get minBidIncrement;// Status
 String get status;@JsonKey(name: 'start_time') DateTime? get startTime;@JsonKey(name: 'end_time') DateTime? get endTime;@JsonKey(name: 'winner_id') String? get winnerId;// Live stream — empty string means no stream active
@JsonKey(name: 'stream_url') String get streamUrl;
/// Create a copy of AuctionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionModelCopyWith<AuctionModel> get copyWith => _$AuctionModelCopyWithImpl<AuctionModel>(this as AuctionModel, _$identity);

  /// Serializes this AuctionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.startPrice, startPrice) || other.startPrice == startPrice)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.minBidIncrement, minBidIncrement) || other.minBidIncrement == minBidIncrement)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,title,description,category,condition,city,const DeepCollectionEquality().hash(images),startPrice,currentPrice,minBidIncrement,status,startTime,endTime,winnerId,streamUrl);

@override
String toString() {
  return 'AuctionModel(id: $id, itemId: $itemId, title: $title, description: $description, category: $category, condition: $condition, city: $city, images: $images, startPrice: $startPrice, currentPrice: $currentPrice, minBidIncrement: $minBidIncrement, status: $status, startTime: $startTime, endTime: $endTime, winnerId: $winnerId, streamUrl: $streamUrl)';
}


}

/// @nodoc
abstract mixin class $AuctionModelCopyWith<$Res>  {
  factory $AuctionModelCopyWith(AuctionModel value, $Res Function(AuctionModel) _then) = _$AuctionModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'item_id') String? itemId, String title, String description, String? category, String? condition, String? city, List<String> images,@JsonKey(name: 'start_price')@_MoneyConverter() int? startPrice,@JsonKey(name: 'current_price')@_MoneyConverter() int? currentPrice,@JsonKey(name: 'min_bid_increment')@_MoneyConverter() int? minBidIncrement, String status,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'stream_url') String streamUrl
});




}
/// @nodoc
class _$AuctionModelCopyWithImpl<$Res>
    implements $AuctionModelCopyWith<$Res> {
  _$AuctionModelCopyWithImpl(this._self, this._then);

  final AuctionModel _self;
  final $Res Function(AuctionModel) _then;

/// Create a copy of AuctionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? itemId = freezed,Object? title = null,Object? description = null,Object? category = freezed,Object? condition = freezed,Object? city = freezed,Object? images = null,Object? startPrice = freezed,Object? currentPrice = freezed,Object? minBidIncrement = freezed,Object? status = null,Object? startTime = freezed,Object? endTime = freezed,Object? winnerId = freezed,Object? streamUrl = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,startPrice: freezed == startPrice ? _self.startPrice : startPrice // ignore: cast_nullable_to_non_nullable
as int?,currentPrice: freezed == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as int?,minBidIncrement: freezed == minBidIncrement ? _self.minBidIncrement : minBidIncrement // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: null == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AuctionModel].
extension AuctionModelPatterns on AuctionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuctionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuctionModel value)  $default,){
final _that = this;
switch (_that) {
case _AuctionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuctionModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'item_id')  String? itemId,  String title,  String description,  String? category,  String? condition,  String? city,  List<String> images, @JsonKey(name: 'start_price')@_MoneyConverter()  int? startPrice, @JsonKey(name: 'current_price')@_MoneyConverter()  int? currentPrice, @JsonKey(name: 'min_bid_increment')@_MoneyConverter()  int? minBidIncrement,  String status, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'stream_url')  String streamUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
return $default(_that.id,_that.itemId,_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images,_that.startPrice,_that.currentPrice,_that.minBidIncrement,_that.status,_that.startTime,_that.endTime,_that.winnerId,_that.streamUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'item_id')  String? itemId,  String title,  String description,  String? category,  String? condition,  String? city,  List<String> images, @JsonKey(name: 'start_price')@_MoneyConverter()  int? startPrice, @JsonKey(name: 'current_price')@_MoneyConverter()  int? currentPrice, @JsonKey(name: 'min_bid_increment')@_MoneyConverter()  int? minBidIncrement,  String status, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'stream_url')  String streamUrl)  $default,) {final _that = this;
switch (_that) {
case _AuctionModel():
return $default(_that.id,_that.itemId,_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images,_that.startPrice,_that.currentPrice,_that.minBidIncrement,_that.status,_that.startTime,_that.endTime,_that.winnerId,_that.streamUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'item_id')  String? itemId,  String title,  String description,  String? category,  String? condition,  String? city,  List<String> images, @JsonKey(name: 'start_price')@_MoneyConverter()  int? startPrice, @JsonKey(name: 'current_price')@_MoneyConverter()  int? currentPrice, @JsonKey(name: 'min_bid_increment')@_MoneyConverter()  int? minBidIncrement,  String status, @JsonKey(name: 'start_time')  DateTime? startTime, @JsonKey(name: 'end_time')  DateTime? endTime, @JsonKey(name: 'winner_id')  String? winnerId, @JsonKey(name: 'stream_url')  String streamUrl)?  $default,) {final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
return $default(_that.id,_that.itemId,_that.title,_that.description,_that.category,_that.condition,_that.city,_that.images,_that.startPrice,_that.currentPrice,_that.minBidIncrement,_that.status,_that.startTime,_that.endTime,_that.winnerId,_that.streamUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionModel implements AuctionModel {
  const _AuctionModel({this.id, @JsonKey(name: 'item_id') this.itemId, this.title = '', this.description = '', this.category, this.condition, this.city, final  List<String> images = const [], @JsonKey(name: 'start_price')@_MoneyConverter() this.startPrice, @JsonKey(name: 'current_price')@_MoneyConverter() this.currentPrice, @JsonKey(name: 'min_bid_increment')@_MoneyConverter() this.minBidIncrement, this.status = 'active', @JsonKey(name: 'start_time') this.startTime, @JsonKey(name: 'end_time') this.endTime, @JsonKey(name: 'winner_id') this.winnerId, @JsonKey(name: 'stream_url') this.streamUrl = ''}): _images = images;
  factory _AuctionModel.fromJson(Map<String, dynamic> json) => _$AuctionModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'item_id') final  String? itemId;
// Flattened from nested `item` object via custom fromJson below.
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  String? category;
@override final  String? condition;
@override final  String? city;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

// Monetary fields — API sends as strings.
@override@JsonKey(name: 'start_price')@_MoneyConverter() final  int? startPrice;
@override@JsonKey(name: 'current_price')@_MoneyConverter() final  int? currentPrice;
@override@JsonKey(name: 'min_bid_increment')@_MoneyConverter() final  int? minBidIncrement;
// Status
@override@JsonKey() final  String status;
@override@JsonKey(name: 'start_time') final  DateTime? startTime;
@override@JsonKey(name: 'end_time') final  DateTime? endTime;
@override@JsonKey(name: 'winner_id') final  String? winnerId;
// Live stream — empty string means no stream active
@override@JsonKey(name: 'stream_url') final  String streamUrl;

/// Create a copy of AuctionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuctionModelCopyWith<_AuctionModel> get copyWith => __$AuctionModelCopyWithImpl<_AuctionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuctionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.startPrice, startPrice) || other.startPrice == startPrice)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.minBidIncrement, minBidIncrement) || other.minBidIncrement == minBidIncrement)&&(identical(other.status, status) || other.status == status)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.winnerId, winnerId) || other.winnerId == winnerId)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,title,description,category,condition,city,const DeepCollectionEquality().hash(_images),startPrice,currentPrice,minBidIncrement,status,startTime,endTime,winnerId,streamUrl);

@override
String toString() {
  return 'AuctionModel(id: $id, itemId: $itemId, title: $title, description: $description, category: $category, condition: $condition, city: $city, images: $images, startPrice: $startPrice, currentPrice: $currentPrice, minBidIncrement: $minBidIncrement, status: $status, startTime: $startTime, endTime: $endTime, winnerId: $winnerId, streamUrl: $streamUrl)';
}


}

/// @nodoc
abstract mixin class _$AuctionModelCopyWith<$Res> implements $AuctionModelCopyWith<$Res> {
  factory _$AuctionModelCopyWith(_AuctionModel value, $Res Function(_AuctionModel) _then) = __$AuctionModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'item_id') String? itemId, String title, String description, String? category, String? condition, String? city, List<String> images,@JsonKey(name: 'start_price')@_MoneyConverter() int? startPrice,@JsonKey(name: 'current_price')@_MoneyConverter() int? currentPrice,@JsonKey(name: 'min_bid_increment')@_MoneyConverter() int? minBidIncrement, String status,@JsonKey(name: 'start_time') DateTime? startTime,@JsonKey(name: 'end_time') DateTime? endTime,@JsonKey(name: 'winner_id') String? winnerId,@JsonKey(name: 'stream_url') String streamUrl
});




}
/// @nodoc
class __$AuctionModelCopyWithImpl<$Res>
    implements _$AuctionModelCopyWith<$Res> {
  __$AuctionModelCopyWithImpl(this._self, this._then);

  final _AuctionModel _self;
  final $Res Function(_AuctionModel) _then;

/// Create a copy of AuctionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? itemId = freezed,Object? title = null,Object? description = null,Object? category = freezed,Object? condition = freezed,Object? city = freezed,Object? images = null,Object? startPrice = freezed,Object? currentPrice = freezed,Object? minBidIncrement = freezed,Object? status = null,Object? startTime = freezed,Object? endTime = freezed,Object? winnerId = freezed,Object? streamUrl = null,}) {
  return _then(_AuctionModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,startPrice: freezed == startPrice ? _self.startPrice : startPrice // ignore: cast_nullable_to_non_nullable
as int?,currentPrice: freezed == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as int?,minBidIncrement: freezed == minBidIncrement ? _self.minBidIncrement : minBidIncrement // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,winnerId: freezed == winnerId ? _self.winnerId : winnerId // ignore: cast_nullable_to_non_nullable
as String?,streamUrl: null == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CreateAuctionRequest {

 String get title; String get description; String get category; String get condition; String get city;@JsonKey(name: 'start_price') int get startPrice;@JsonKey(name: 'min_bid_increment') int get minBidIncrement;@JsonKey(name: 'duration_hours') int get durationHours; List<String> get images;@JsonKey(name: 'stream_url') String? get streamUrl;
/// Create a copy of CreateAuctionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateAuctionRequestCopyWith<CreateAuctionRequest> get copyWith => _$CreateAuctionRequestCopyWithImpl<CreateAuctionRequest>(this as CreateAuctionRequest, _$identity);

  /// Serializes this CreateAuctionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateAuctionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&(identical(other.startPrice, startPrice) || other.startPrice == startPrice)&&(identical(other.minBidIncrement, minBidIncrement) || other.minBidIncrement == minBidIncrement)&&(identical(other.durationHours, durationHours) || other.durationHours == durationHours)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,condition,city,startPrice,minBidIncrement,durationHours,const DeepCollectionEquality().hash(images),streamUrl);

@override
String toString() {
  return 'CreateAuctionRequest(title: $title, description: $description, category: $category, condition: $condition, city: $city, startPrice: $startPrice, minBidIncrement: $minBidIncrement, durationHours: $durationHours, images: $images, streamUrl: $streamUrl)';
}


}

/// @nodoc
abstract mixin class $CreateAuctionRequestCopyWith<$Res>  {
  factory $CreateAuctionRequestCopyWith(CreateAuctionRequest value, $Res Function(CreateAuctionRequest) _then) = _$CreateAuctionRequestCopyWithImpl;
@useResult
$Res call({
 String title, String description, String category, String condition, String city,@JsonKey(name: 'start_price') int startPrice,@JsonKey(name: 'min_bid_increment') int minBidIncrement,@JsonKey(name: 'duration_hours') int durationHours, List<String> images,@JsonKey(name: 'stream_url') String? streamUrl
});




}
/// @nodoc
class _$CreateAuctionRequestCopyWithImpl<$Res>
    implements $CreateAuctionRequestCopyWith<$Res> {
  _$CreateAuctionRequestCopyWithImpl(this._self, this._then);

  final CreateAuctionRequest _self;
  final $Res Function(CreateAuctionRequest) _then;

/// Create a copy of CreateAuctionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? category = null,Object? condition = null,Object? city = null,Object? startPrice = null,Object? minBidIncrement = null,Object? durationHours = null,Object? images = null,Object? streamUrl = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,startPrice: null == startPrice ? _self.startPrice : startPrice // ignore: cast_nullable_to_non_nullable
as int,minBidIncrement: null == minBidIncrement ? _self.minBidIncrement : minBidIncrement // ignore: cast_nullable_to_non_nullable
as int,durationHours: null == durationHours ? _self.durationHours : durationHours // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateAuctionRequest].
extension CreateAuctionRequestPatterns on CreateAuctionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateAuctionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateAuctionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateAuctionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateAuctionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String category,  String condition,  String city, @JsonKey(name: 'start_price')  int startPrice, @JsonKey(name: 'min_bid_increment')  int minBidIncrement, @JsonKey(name: 'duration_hours')  int durationHours,  List<String> images, @JsonKey(name: 'stream_url')  String? streamUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.startPrice,_that.minBidIncrement,_that.durationHours,_that.images,_that.streamUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String category,  String condition,  String city, @JsonKey(name: 'start_price')  int startPrice, @JsonKey(name: 'min_bid_increment')  int minBidIncrement, @JsonKey(name: 'duration_hours')  int durationHours,  List<String> images, @JsonKey(name: 'stream_url')  String? streamUrl)  $default,) {final _that = this;
switch (_that) {
case _CreateAuctionRequest():
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.startPrice,_that.minBidIncrement,_that.durationHours,_that.images,_that.streamUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String category,  String condition,  String city, @JsonKey(name: 'start_price')  int startPrice, @JsonKey(name: 'min_bid_increment')  int minBidIncrement, @JsonKey(name: 'duration_hours')  int durationHours,  List<String> images, @JsonKey(name: 'stream_url')  String? streamUrl)?  $default,) {final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.condition,_that.city,_that.startPrice,_that.minBidIncrement,_that.durationHours,_that.images,_that.streamUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateAuctionRequest implements CreateAuctionRequest {
  const _CreateAuctionRequest({required this.title, required this.description, required this.category, required this.condition, required this.city, @JsonKey(name: 'start_price') required this.startPrice, @JsonKey(name: 'min_bid_increment') required this.minBidIncrement, @JsonKey(name: 'duration_hours') required this.durationHours, final  List<String> images = const [], @JsonKey(name: 'stream_url') this.streamUrl}): _images = images;
  factory _CreateAuctionRequest.fromJson(Map<String, dynamic> json) => _$CreateAuctionRequestFromJson(json);

@override final  String title;
@override final  String description;
@override final  String category;
@override final  String condition;
@override final  String city;
@override@JsonKey(name: 'start_price') final  int startPrice;
@override@JsonKey(name: 'min_bid_increment') final  int minBidIncrement;
@override@JsonKey(name: 'duration_hours') final  int durationHours;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'stream_url') final  String? streamUrl;

/// Create a copy of CreateAuctionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateAuctionRequestCopyWith<_CreateAuctionRequest> get copyWith => __$CreateAuctionRequestCopyWithImpl<_CreateAuctionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateAuctionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateAuctionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.city, city) || other.city == city)&&(identical(other.startPrice, startPrice) || other.startPrice == startPrice)&&(identical(other.minBidIncrement, minBidIncrement) || other.minBidIncrement == minBidIncrement)&&(identical(other.durationHours, durationHours) || other.durationHours == durationHours)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,condition,city,startPrice,minBidIncrement,durationHours,const DeepCollectionEquality().hash(_images),streamUrl);

@override
String toString() {
  return 'CreateAuctionRequest(title: $title, description: $description, category: $category, condition: $condition, city: $city, startPrice: $startPrice, minBidIncrement: $minBidIncrement, durationHours: $durationHours, images: $images, streamUrl: $streamUrl)';
}


}

/// @nodoc
abstract mixin class _$CreateAuctionRequestCopyWith<$Res> implements $CreateAuctionRequestCopyWith<$Res> {
  factory _$CreateAuctionRequestCopyWith(_CreateAuctionRequest value, $Res Function(_CreateAuctionRequest) _then) = __$CreateAuctionRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String category, String condition, String city,@JsonKey(name: 'start_price') int startPrice,@JsonKey(name: 'min_bid_increment') int minBidIncrement,@JsonKey(name: 'duration_hours') int durationHours, List<String> images,@JsonKey(name: 'stream_url') String? streamUrl
});




}
/// @nodoc
class __$CreateAuctionRequestCopyWithImpl<$Res>
    implements _$CreateAuctionRequestCopyWith<$Res> {
  __$CreateAuctionRequestCopyWithImpl(this._self, this._then);

  final _CreateAuctionRequest _self;
  final $Res Function(_CreateAuctionRequest) _then;

/// Create a copy of CreateAuctionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? category = null,Object? condition = null,Object? city = null,Object? startPrice = null,Object? minBidIncrement = null,Object? durationHours = null,Object? images = null,Object? streamUrl = freezed,}) {
  return _then(_CreateAuctionRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,startPrice: null == startPrice ? _self.startPrice : startPrice // ignore: cast_nullable_to_non_nullable
as int,minBidIncrement: null == minBidIncrement ? _self.minBidIncrement : minBidIncrement // ignore: cast_nullable_to_non_nullable
as int,durationHours: null == durationHours ? _self.durationHours : durationHours // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PlaceBidRequest {

 int get amount;
/// Create a copy of PlaceBidRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaceBidRequestCopyWith<PlaceBidRequest> get copyWith => _$PlaceBidRequestCopyWithImpl<PlaceBidRequest>(this as PlaceBidRequest, _$identity);

  /// Serializes this PlaceBidRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaceBidRequest&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'PlaceBidRequest(amount: $amount)';
}


}

/// @nodoc
abstract mixin class $PlaceBidRequestCopyWith<$Res>  {
  factory $PlaceBidRequestCopyWith(PlaceBidRequest value, $Res Function(PlaceBidRequest) _then) = _$PlaceBidRequestCopyWithImpl;
@useResult
$Res call({
 int amount
});




}
/// @nodoc
class _$PlaceBidRequestCopyWithImpl<$Res>
    implements $PlaceBidRequestCopyWith<$Res> {
  _$PlaceBidRequestCopyWithImpl(this._self, this._then);

  final PlaceBidRequest _self;
  final $Res Function(PlaceBidRequest) _then;

/// Create a copy of PlaceBidRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaceBidRequest].
extension PlaceBidRequestPatterns on PlaceBidRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaceBidRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaceBidRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaceBidRequest value)  $default,){
final _that = this;
switch (_that) {
case _PlaceBidRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaceBidRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PlaceBidRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaceBidRequest() when $default != null:
return $default(_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int amount)  $default,) {final _that = this;
switch (_that) {
case _PlaceBidRequest():
return $default(_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int amount)?  $default,) {final _that = this;
switch (_that) {
case _PlaceBidRequest() when $default != null:
return $default(_that.amount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaceBidRequest implements PlaceBidRequest {
  const _PlaceBidRequest({required this.amount});
  factory _PlaceBidRequest.fromJson(Map<String, dynamic> json) => _$PlaceBidRequestFromJson(json);

@override final  int amount;

/// Create a copy of PlaceBidRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaceBidRequestCopyWith<_PlaceBidRequest> get copyWith => __$PlaceBidRequestCopyWithImpl<_PlaceBidRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaceBidRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaceBidRequest&&(identical(other.amount, amount) || other.amount == amount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount);

@override
String toString() {
  return 'PlaceBidRequest(amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$PlaceBidRequestCopyWith<$Res> implements $PlaceBidRequestCopyWith<$Res> {
  factory _$PlaceBidRequestCopyWith(_PlaceBidRequest value, $Res Function(_PlaceBidRequest) _then) = __$PlaceBidRequestCopyWithImpl;
@override @useResult
$Res call({
 int amount
});




}
/// @nodoc
class __$PlaceBidRequestCopyWithImpl<$Res>
    implements _$PlaceBidRequestCopyWith<$Res> {
  __$PlaceBidRequestCopyWithImpl(this._self, this._then);

  final _PlaceBidRequest _self;
  final $Res Function(_PlaceBidRequest) _then;

/// Create a copy of PlaceBidRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,}) {
  return _then(_PlaceBidRequest(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BidModel {

 String get id;@JsonKey(name: 'auction_id') String? get auctionId;@JsonKey(name: 'bidder_id') String get bidderId;@_MoneyConverter() int get amount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidModelCopyWith<BidModel> get copyWith => _$BidModelCopyWithImpl<BidModel>(this as BidModel, _$identity);

  /// Serializes this BidModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auctionId,bidderId,amount,createdAt);

@override
String toString() {
  return 'BidModel(id: $id, auctionId: $auctionId, bidderId: $bidderId, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BidModelCopyWith<$Res>  {
  factory $BidModelCopyWith(BidModel value, $Res Function(BidModel) _then) = _$BidModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'auction_id') String? auctionId,@JsonKey(name: 'bidder_id') String bidderId,@_MoneyConverter() int amount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BidModelCopyWithImpl<$Res>
    implements $BidModelCopyWith<$Res> {
  _$BidModelCopyWithImpl(this._self, this._then);

  final BidModel _self;
  final $Res Function(BidModel) _then;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? auctionId = freezed,Object? bidderId = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auctionId: freezed == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String?,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BidModel].
extension BidModelPatterns on BidModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BidModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BidModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BidModel value)  $default,){
final _that = this;
switch (_that) {
case _BidModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BidModel value)?  $default,){
final _that = this;
switch (_that) {
case _BidModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'auction_id')  String? auctionId, @JsonKey(name: 'bidder_id')  String bidderId, @_MoneyConverter()  int amount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'auction_id')  String? auctionId, @JsonKey(name: 'bidder_id')  String bidderId, @_MoneyConverter()  int amount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BidModel():
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'auction_id')  String? auctionId, @JsonKey(name: 'bidder_id')  String bidderId, @_MoneyConverter()  int amount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.id,_that.auctionId,_that.bidderId,_that.amount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BidModel implements BidModel {
  const _BidModel({required this.id, @JsonKey(name: 'auction_id') this.auctionId, @JsonKey(name: 'bidder_id') required this.bidderId, @_MoneyConverter() required this.amount, @JsonKey(name: 'created_at') required this.createdAt});
  factory _BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'auction_id') final  String? auctionId;
@override@JsonKey(name: 'bidder_id') final  String bidderId;
@override@_MoneyConverter() final  int amount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidModelCopyWith<_BidModel> get copyWith => __$BidModelCopyWithImpl<_BidModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.auctionId, auctionId) || other.auctionId == auctionId)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,auctionId,bidderId,amount,createdAt);

@override
String toString() {
  return 'BidModel(id: $id, auctionId: $auctionId, bidderId: $bidderId, amount: $amount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BidModelCopyWith<$Res> implements $BidModelCopyWith<$Res> {
  factory _$BidModelCopyWith(_BidModel value, $Res Function(_BidModel) _then) = __$BidModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'auction_id') String? auctionId,@JsonKey(name: 'bidder_id') String bidderId,@_MoneyConverter() int amount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BidModelCopyWithImpl<$Res>
    implements _$BidModelCopyWith<$Res> {
  __$BidModelCopyWithImpl(this._self, this._then);

  final _BidModel _self;
  final $Res Function(_BidModel) _then;

/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? auctionId = freezed,Object? bidderId = null,Object? amount = null,Object? createdAt = null,}) {
  return _then(_BidModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,auctionId: freezed == auctionId ? _self.auctionId : auctionId // ignore: cast_nullable_to_non_nullable
as String?,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
