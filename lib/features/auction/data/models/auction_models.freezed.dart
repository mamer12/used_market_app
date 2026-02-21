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
mixin _$AuctionModel {

 String? get id; String get title; String get description;@JsonKey(name: 'current_price') double? get currentPrice;@JsonKey(name: 'end_time') DateTime? get endTime; List<String> get images;
/// Create a copy of AuctionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuctionModelCopyWith<AuctionModel> get copyWith => _$AuctionModelCopyWithImpl<AuctionModel>(this as AuctionModel, _$identity);

  /// Serializes this AuctionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,currentPrice,endTime,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'AuctionModel(id: $id, title: $title, description: $description, currentPrice: $currentPrice, endTime: $endTime, images: $images)';
}


}

/// @nodoc
abstract mixin class $AuctionModelCopyWith<$Res>  {
  factory $AuctionModelCopyWith(AuctionModel value, $Res Function(AuctionModel) _then) = _$AuctionModelCopyWithImpl;
@useResult
$Res call({
 String? id, String title, String description,@JsonKey(name: 'current_price') double? currentPrice,@JsonKey(name: 'end_time') DateTime? endTime, List<String> images
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? currentPrice = freezed,Object? endTime = freezed,Object? images = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,currentPrice: freezed == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String title,  String description, @JsonKey(name: 'current_price')  double? currentPrice, @JsonKey(name: 'end_time')  DateTime? endTime,  List<String> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.currentPrice,_that.endTime,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String title,  String description, @JsonKey(name: 'current_price')  double? currentPrice, @JsonKey(name: 'end_time')  DateTime? endTime,  List<String> images)  $default,) {final _that = this;
switch (_that) {
case _AuctionModel():
return $default(_that.id,_that.title,_that.description,_that.currentPrice,_that.endTime,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String title,  String description, @JsonKey(name: 'current_price')  double? currentPrice, @JsonKey(name: 'end_time')  DateTime? endTime,  List<String> images)?  $default,) {final _that = this;
switch (_that) {
case _AuctionModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.currentPrice,_that.endTime,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuctionModel implements AuctionModel {
  const _AuctionModel({this.id, this.title = '', this.description = '', @JsonKey(name: 'current_price') this.currentPrice, @JsonKey(name: 'end_time') this.endTime, final  List<String> images = const []}): _images = images;
  factory _AuctionModel.fromJson(Map<String, dynamic> json) => _$AuctionModelFromJson(json);

@override final  String? id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'current_price') final  double? currentPrice;
@override@JsonKey(name: 'end_time') final  DateTime? endTime;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuctionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.currentPrice, currentPrice) || other.currentPrice == currentPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,currentPrice,endTime,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'AuctionModel(id: $id, title: $title, description: $description, currentPrice: $currentPrice, endTime: $endTime, images: $images)';
}


}

/// @nodoc
abstract mixin class _$AuctionModelCopyWith<$Res> implements $AuctionModelCopyWith<$Res> {
  factory _$AuctionModelCopyWith(_AuctionModel value, $Res Function(_AuctionModel) _then) = __$AuctionModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String title, String description,@JsonKey(name: 'current_price') double? currentPrice,@JsonKey(name: 'end_time') DateTime? endTime, List<String> images
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = null,Object? description = null,Object? currentPrice = freezed,Object? endTime = freezed,Object? images = null,}) {
  return _then(_AuctionModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,currentPrice: freezed == currentPrice ? _self.currentPrice : currentPrice // ignore: cast_nullable_to_non_nullable
as double?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CreateAuctionRequest {

 String get title; String get description;@JsonKey(name: 'starting_price') double get startingPrice;@JsonKey(name: 'end_time') DateTime get endTime; List<String> get images;
/// Create a copy of CreateAuctionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateAuctionRequestCopyWith<CreateAuctionRequest> get copyWith => _$CreateAuctionRequestCopyWithImpl<CreateAuctionRequest>(this as CreateAuctionRequest, _$identity);

  /// Serializes this CreateAuctionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateAuctionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startingPrice, startingPrice) || other.startingPrice == startingPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,startingPrice,endTime,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'CreateAuctionRequest(title: $title, description: $description, startingPrice: $startingPrice, endTime: $endTime, images: $images)';
}


}

/// @nodoc
abstract mixin class $CreateAuctionRequestCopyWith<$Res>  {
  factory $CreateAuctionRequestCopyWith(CreateAuctionRequest value, $Res Function(CreateAuctionRequest) _then) = _$CreateAuctionRequestCopyWithImpl;
@useResult
$Res call({
 String title, String description,@JsonKey(name: 'starting_price') double startingPrice,@JsonKey(name: 'end_time') DateTime endTime, List<String> images
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
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? startingPrice = null,Object? endTime = null,Object? images = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startingPrice: null == startingPrice ? _self.startingPrice : startingPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'end_time')  DateTime endTime,  List<String> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
return $default(_that.title,_that.description,_that.startingPrice,_that.endTime,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'end_time')  DateTime endTime,  List<String> images)  $default,) {final _that = this;
switch (_that) {
case _CreateAuctionRequest():
return $default(_that.title,_that.description,_that.startingPrice,_that.endTime,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description, @JsonKey(name: 'starting_price')  double startingPrice, @JsonKey(name: 'end_time')  DateTime endTime,  List<String> images)?  $default,) {final _that = this;
switch (_that) {
case _CreateAuctionRequest() when $default != null:
return $default(_that.title,_that.description,_that.startingPrice,_that.endTime,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateAuctionRequest implements CreateAuctionRequest {
  const _CreateAuctionRequest({required this.title, required this.description, @JsonKey(name: 'starting_price') required this.startingPrice, @JsonKey(name: 'end_time') required this.endTime, required final  List<String> images}): _images = images;
  factory _CreateAuctionRequest.fromJson(Map<String, dynamic> json) => _$CreateAuctionRequestFromJson(json);

@override final  String title;
@override final  String description;
@override@JsonKey(name: 'starting_price') final  double startingPrice;
@override@JsonKey(name: 'end_time') final  DateTime endTime;
 final  List<String> _images;
@override List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateAuctionRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.startingPrice, startingPrice) || other.startingPrice == startingPrice)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,startingPrice,endTime,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'CreateAuctionRequest(title: $title, description: $description, startingPrice: $startingPrice, endTime: $endTime, images: $images)';
}


}

/// @nodoc
abstract mixin class _$CreateAuctionRequestCopyWith<$Res> implements $CreateAuctionRequestCopyWith<$Res> {
  factory _$CreateAuctionRequestCopyWith(_CreateAuctionRequest value, $Res Function(_CreateAuctionRequest) _then) = __$CreateAuctionRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, String description,@JsonKey(name: 'starting_price') double startingPrice,@JsonKey(name: 'end_time') DateTime endTime, List<String> images
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
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? startingPrice = null,Object? endTime = null,Object? images = null,}) {
  return _then(_CreateAuctionRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startingPrice: null == startingPrice ? _self.startingPrice : startingPrice // ignore: cast_nullable_to_non_nullable
as double,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$BidModel {

 String get id; double get amount;@JsonKey(name: 'bidder_id') String get bidderId;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of BidModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidModelCopyWith<BidModel> get copyWith => _$BidModelCopyWithImpl<BidModel>(this as BidModel, _$identity);

  /// Serializes this BidModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,bidderId,createdAt);

@override
String toString() {
  return 'BidModel(id: $id, amount: $amount, bidderId: $bidderId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BidModelCopyWith<$Res>  {
  factory $BidModelCopyWith(BidModel value, $Res Function(BidModel) _then) = _$BidModelCopyWithImpl;
@useResult
$Res call({
 String id, double amount,@JsonKey(name: 'bidder_id') String bidderId,@JsonKey(name: 'created_at') DateTime createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? bidderId = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount, @JsonKey(name: 'bidder_id')  String bidderId, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.id,_that.amount,_that.bidderId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount, @JsonKey(name: 'bidder_id')  String bidderId, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BidModel():
return $default(_that.id,_that.amount,_that.bidderId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount, @JsonKey(name: 'bidder_id')  String bidderId, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BidModel() when $default != null:
return $default(_that.id,_that.amount,_that.bidderId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BidModel implements BidModel {
  const _BidModel({required this.id, required this.amount, @JsonKey(name: 'bidder_id') required this.bidderId, @JsonKey(name: 'created_at') required this.createdAt});
  factory _BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);

@override final  String id;
@override final  double amount;
@override@JsonKey(name: 'bidder_id') final  String bidderId;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BidModel&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.bidderId, bidderId) || other.bidderId == bidderId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,bidderId,createdAt);

@override
String toString() {
  return 'BidModel(id: $id, amount: $amount, bidderId: $bidderId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BidModelCopyWith<$Res> implements $BidModelCopyWith<$Res> {
  factory _$BidModelCopyWith(_BidModel value, $Res Function(_BidModel) _then) = __$BidModelCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount,@JsonKey(name: 'bidder_id') String bidderId,@JsonKey(name: 'created_at') DateTime createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? bidderId = null,Object? createdAt = null,}) {
  return _then(_BidModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,bidderId: null == bidderId ? _self.bidderId : bidderId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
