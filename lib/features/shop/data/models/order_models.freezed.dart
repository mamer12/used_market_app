// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShippingAddress {

 String get city; String get district; String get street; String get building; String get phone;
/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<ShippingAddress> get copyWith => _$ShippingAddressCopyWithImpl<ShippingAddress>(this as ShippingAddress, _$identity);

  /// Serializes this ShippingAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShippingAddress&&(identical(other.city, city) || other.city == city)&&(identical(other.district, district) || other.district == district)&&(identical(other.street, street) || other.street == street)&&(identical(other.building, building) || other.building == building)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,district,street,building,phone);

@override
String toString() {
  return 'ShippingAddress(city: $city, district: $district, street: $street, building: $building, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $ShippingAddressCopyWith<$Res>  {
  factory $ShippingAddressCopyWith(ShippingAddress value, $Res Function(ShippingAddress) _then) = _$ShippingAddressCopyWithImpl;
@useResult
$Res call({
 String city, String district, String street, String building, String phone
});




}
/// @nodoc
class _$ShippingAddressCopyWithImpl<$Res>
    implements $ShippingAddressCopyWith<$Res> {
  _$ShippingAddressCopyWithImpl(this._self, this._then);

  final ShippingAddress _self;
  final $Res Function(ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? city = null,Object? district = null,Object? street = null,Object? building = null,Object? phone = null,}) {
  return _then(_self.copyWith(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,building: null == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShippingAddress].
extension ShippingAddressPatterns on ShippingAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShippingAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShippingAddress value)  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShippingAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String city,  String district,  String street,  String building,  String phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.city,_that.district,_that.street,_that.building,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String city,  String district,  String street,  String building,  String phone)  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress():
return $default(_that.city,_that.district,_that.street,_that.building,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String city,  String district,  String street,  String building,  String phone)?  $default,) {final _that = this;
switch (_that) {
case _ShippingAddress() when $default != null:
return $default(_that.city,_that.district,_that.street,_that.building,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShippingAddress implements ShippingAddress {
  const _ShippingAddress({required this.city, required this.district, required this.street, required this.building, required this.phone});
  factory _ShippingAddress.fromJson(Map<String, dynamic> json) => _$ShippingAddressFromJson(json);

@override final  String city;
@override final  String district;
@override final  String street;
@override final  String building;
@override final  String phone;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShippingAddressCopyWith<_ShippingAddress> get copyWith => __$ShippingAddressCopyWithImpl<_ShippingAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShippingAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShippingAddress&&(identical(other.city, city) || other.city == city)&&(identical(other.district, district) || other.district == district)&&(identical(other.street, street) || other.street == street)&&(identical(other.building, building) || other.building == building)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,city,district,street,building,phone);

@override
String toString() {
  return 'ShippingAddress(city: $city, district: $district, street: $street, building: $building, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$ShippingAddressCopyWith<$Res> implements $ShippingAddressCopyWith<$Res> {
  factory _$ShippingAddressCopyWith(_ShippingAddress value, $Res Function(_ShippingAddress) _then) = __$ShippingAddressCopyWithImpl;
@override @useResult
$Res call({
 String city, String district, String street, String building, String phone
});




}
/// @nodoc
class __$ShippingAddressCopyWithImpl<$Res>
    implements _$ShippingAddressCopyWith<$Res> {
  __$ShippingAddressCopyWithImpl(this._self, this._then);

  final _ShippingAddress _self;
  final $Res Function(_ShippingAddress) _then;

/// Create a copy of ShippingAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? city = null,Object? district = null,Object? street = null,Object? building = null,Object? phone = null,}) {
  return _then(_ShippingAddress(
city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,street: null == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String,building: null == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$OrderModel {

 String get id;@JsonKey(name: 'product_id') String get productId;@JsonKey(name: 'buyer_id') String get buyerId;@JsonKey(name: 'seller_id') String get sellerId; int get quantity;@JsonKey(name: 'total_price') double get totalPrice; OrderStatus get status;@JsonKey(name: 'shipping_address') ShippingAddress get shippingAddress;@JsonKey(name: 'fulfillment_type') String get fulfillmentType;@JsonKey(name: 'payment_url') String? get paymentUrl;@JsonKey(name: 'product_name') String? get productName;@JsonKey(name: 'product_image') String? get productImage;
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderModelCopyWith<OrderModel> get copyWith => _$OrderModelCopyWithImpl<OrderModel>(this as OrderModel, _$identity);

  /// Serializes this OrderModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.paymentUrl, paymentUrl) || other.paymentUrl == paymentUrl)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,buyerId,sellerId,quantity,totalPrice,status,shippingAddress,fulfillmentType,paymentUrl,productName,productImage);

@override
String toString() {
  return 'OrderModel(id: $id, productId: $productId, buyerId: $buyerId, sellerId: $sellerId, quantity: $quantity, totalPrice: $totalPrice, status: $status, shippingAddress: $shippingAddress, fulfillmentType: $fulfillmentType, paymentUrl: $paymentUrl, productName: $productName, productImage: $productImage)';
}


}

/// @nodoc
abstract mixin class $OrderModelCopyWith<$Res>  {
  factory $OrderModelCopyWith(OrderModel value, $Res Function(OrderModel) _then) = _$OrderModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId, int quantity,@JsonKey(name: 'total_price') double totalPrice, OrderStatus status,@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'payment_url') String? paymentUrl,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_image') String? productImage
});


$ShippingAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class _$OrderModelCopyWithImpl<$Res>
    implements $OrderModelCopyWith<$Res> {
  _$OrderModelCopyWithImpl(this._self, this._then);

  final OrderModel _self;
  final $Res Function(OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? buyerId = null,Object? sellerId = null,Object? quantity = null,Object? totalPrice = null,Object? status = null,Object? shippingAddress = null,Object? fulfillmentType = null,Object? paymentUrl = freezed,Object? productName = freezed,Object? productImage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,paymentUrl: freezed == paymentUrl ? _self.paymentUrl : paymentUrl // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderModel].
extension OrderModelPatterns on OrderModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderModel value)  $default,){
final _that = this;
switch (_that) {
case _OrderModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderModel value)?  $default,){
final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId,  int quantity, @JsonKey(name: 'total_price')  double totalPrice,  OrderStatus status, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_url')  String? paymentUrl, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_image')  String? productImage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.productId,_that.buyerId,_that.sellerId,_that.quantity,_that.totalPrice,_that.status,_that.shippingAddress,_that.fulfillmentType,_that.paymentUrl,_that.productName,_that.productImage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId,  int quantity, @JsonKey(name: 'total_price')  double totalPrice,  OrderStatus status, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_url')  String? paymentUrl, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_image')  String? productImage)  $default,) {final _that = this;
switch (_that) {
case _OrderModel():
return $default(_that.id,_that.productId,_that.buyerId,_that.sellerId,_that.quantity,_that.totalPrice,_that.status,_that.shippingAddress,_that.fulfillmentType,_that.paymentUrl,_that.productName,_that.productImage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'product_id')  String productId, @JsonKey(name: 'buyer_id')  String buyerId, @JsonKey(name: 'seller_id')  String sellerId,  int quantity, @JsonKey(name: 'total_price')  double totalPrice,  OrderStatus status, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'payment_url')  String? paymentUrl, @JsonKey(name: 'product_name')  String? productName, @JsonKey(name: 'product_image')  String? productImage)?  $default,) {final _that = this;
switch (_that) {
case _OrderModel() when $default != null:
return $default(_that.id,_that.productId,_that.buyerId,_that.sellerId,_that.quantity,_that.totalPrice,_that.status,_that.shippingAddress,_that.fulfillmentType,_that.paymentUrl,_that.productName,_that.productImage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderModel implements OrderModel {
  const _OrderModel({required this.id, @JsonKey(name: 'product_id') required this.productId, @JsonKey(name: 'buyer_id') required this.buyerId, @JsonKey(name: 'seller_id') required this.sellerId, required this.quantity, @JsonKey(name: 'total_price') required this.totalPrice, required this.status, @JsonKey(name: 'shipping_address') required this.shippingAddress, @JsonKey(name: 'fulfillment_type') required this.fulfillmentType, @JsonKey(name: 'payment_url') this.paymentUrl, @JsonKey(name: 'product_name') this.productName, @JsonKey(name: 'product_image') this.productImage});
  factory _OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'product_id') final  String productId;
@override@JsonKey(name: 'buyer_id') final  String buyerId;
@override@JsonKey(name: 'seller_id') final  String sellerId;
@override final  int quantity;
@override@JsonKey(name: 'total_price') final  double totalPrice;
@override final  OrderStatus status;
@override@JsonKey(name: 'shipping_address') final  ShippingAddress shippingAddress;
@override@JsonKey(name: 'fulfillment_type') final  String fulfillmentType;
@override@JsonKey(name: 'payment_url') final  String? paymentUrl;
@override@JsonKey(name: 'product_name') final  String? productName;
@override@JsonKey(name: 'product_image') final  String? productImage;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderModelCopyWith<_OrderModel> get copyWith => __$OrderModelCopyWithImpl<_OrderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderModel&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.buyerId, buyerId) || other.buyerId == buyerId)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.status, status) || other.status == status)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.paymentUrl, paymentUrl) || other.paymentUrl == paymentUrl)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,buyerId,sellerId,quantity,totalPrice,status,shippingAddress,fulfillmentType,paymentUrl,productName,productImage);

@override
String toString() {
  return 'OrderModel(id: $id, productId: $productId, buyerId: $buyerId, sellerId: $sellerId, quantity: $quantity, totalPrice: $totalPrice, status: $status, shippingAddress: $shippingAddress, fulfillmentType: $fulfillmentType, paymentUrl: $paymentUrl, productName: $productName, productImage: $productImage)';
}


}

/// @nodoc
abstract mixin class _$OrderModelCopyWith<$Res> implements $OrderModelCopyWith<$Res> {
  factory _$OrderModelCopyWith(_OrderModel value, $Res Function(_OrderModel) _then) = __$OrderModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'product_id') String productId,@JsonKey(name: 'buyer_id') String buyerId,@JsonKey(name: 'seller_id') String sellerId, int quantity,@JsonKey(name: 'total_price') double totalPrice, OrderStatus status,@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'payment_url') String? paymentUrl,@JsonKey(name: 'product_name') String? productName,@JsonKey(name: 'product_image') String? productImage
});


@override $ShippingAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class __$OrderModelCopyWithImpl<$Res>
    implements _$OrderModelCopyWith<$Res> {
  __$OrderModelCopyWithImpl(this._self, this._then);

  final _OrderModel _self;
  final $Res Function(_OrderModel) _then;

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? buyerId = null,Object? sellerId = null,Object? quantity = null,Object? totalPrice = null,Object? status = null,Object? shippingAddress = null,Object? fulfillmentType = null,Object? paymentUrl = freezed,Object? productName = freezed,Object? productImage = freezed,}) {
  return _then(_OrderModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,buyerId: null == buyerId ? _self.buyerId : buyerId // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,paymentUrl: freezed == paymentUrl ? _self.paymentUrl : paymentUrl // ignore: cast_nullable_to_non_nullable
as String?,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,productImage: freezed == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OrderModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// @nodoc
mixin _$BuyProductRequest {

@JsonKey(name: 'product_id') String get productId; int get quantity;@JsonKey(name: 'shipping_address') ShippingAddress get shippingAddress;@JsonKey(name: 'fulfillment_type') String get fulfillmentType;@JsonKey(name: 'app_context') String? get appContext;@JsonKey(name: 'payment_method') String? get paymentMethod;
/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BuyProductRequestCopyWith<BuyProductRequest> get copyWith => _$BuyProductRequestCopyWithImpl<BuyProductRequest>(this as BuyProductRequest, _$identity);

  /// Serializes this BuyProductRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BuyProductRequest&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.appContext, appContext) || other.appContext == appContext)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity,shippingAddress,fulfillmentType,appContext,paymentMethod);

@override
String toString() {
  return 'BuyProductRequest(productId: $productId, quantity: $quantity, shippingAddress: $shippingAddress, fulfillmentType: $fulfillmentType, appContext: $appContext, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class $BuyProductRequestCopyWith<$Res>  {
  factory $BuyProductRequestCopyWith(BuyProductRequest value, $Res Function(BuyProductRequest) _then) = _$BuyProductRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'app_context') String? appContext,@JsonKey(name: 'payment_method') String? paymentMethod
});


$ShippingAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class _$BuyProductRequestCopyWithImpl<$Res>
    implements $BuyProductRequestCopyWith<$Res> {
  _$BuyProductRequestCopyWithImpl(this._self, this._then);

  final BuyProductRequest _self;
  final $Res Function(BuyProductRequest) _then;

/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? quantity = null,Object? shippingAddress = null,Object? fulfillmentType = null,Object? appContext = freezed,Object? paymentMethod = freezed,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,appContext: freezed == appContext ? _self.appContext : appContext // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// Adds pattern-matching-related methods to [BuyProductRequest].
extension BuyProductRequestPatterns on BuyProductRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BuyProductRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BuyProductRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BuyProductRequest value)  $default,){
final _that = this;
switch (_that) {
case _BuyProductRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BuyProductRequest value)?  $default,){
final _that = this;
switch (_that) {
case _BuyProductRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'app_context')  String? appContext, @JsonKey(name: 'payment_method')  String? paymentMethod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BuyProductRequest() when $default != null:
return $default(_that.productId,_that.quantity,_that.shippingAddress,_that.fulfillmentType,_that.appContext,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'app_context')  String? appContext, @JsonKey(name: 'payment_method')  String? paymentMethod)  $default,) {final _that = this;
switch (_that) {
case _BuyProductRequest():
return $default(_that.productId,_that.quantity,_that.shippingAddress,_that.fulfillmentType,_that.appContext,_that.paymentMethod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'product_id')  String productId,  int quantity, @JsonKey(name: 'shipping_address')  ShippingAddress shippingAddress, @JsonKey(name: 'fulfillment_type')  String fulfillmentType, @JsonKey(name: 'app_context')  String? appContext, @JsonKey(name: 'payment_method')  String? paymentMethod)?  $default,) {final _that = this;
switch (_that) {
case _BuyProductRequest() when $default != null:
return $default(_that.productId,_that.quantity,_that.shippingAddress,_that.fulfillmentType,_that.appContext,_that.paymentMethod);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BuyProductRequest implements BuyProductRequest {
  const _BuyProductRequest({@JsonKey(name: 'product_id') required this.productId, required this.quantity, @JsonKey(name: 'shipping_address') required this.shippingAddress, @JsonKey(name: 'fulfillment_type') required this.fulfillmentType, @JsonKey(name: 'app_context') this.appContext, @JsonKey(name: 'payment_method') this.paymentMethod});
  factory _BuyProductRequest.fromJson(Map<String, dynamic> json) => _$BuyProductRequestFromJson(json);

@override@JsonKey(name: 'product_id') final  String productId;
@override final  int quantity;
@override@JsonKey(name: 'shipping_address') final  ShippingAddress shippingAddress;
@override@JsonKey(name: 'fulfillment_type') final  String fulfillmentType;
@override@JsonKey(name: 'app_context') final  String? appContext;
@override@JsonKey(name: 'payment_method') final  String? paymentMethod;

/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BuyProductRequestCopyWith<_BuyProductRequest> get copyWith => __$BuyProductRequestCopyWithImpl<_BuyProductRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BuyProductRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BuyProductRequest&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.shippingAddress, shippingAddress) || other.shippingAddress == shippingAddress)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.appContext, appContext) || other.appContext == appContext)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,quantity,shippingAddress,fulfillmentType,appContext,paymentMethod);

@override
String toString() {
  return 'BuyProductRequest(productId: $productId, quantity: $quantity, shippingAddress: $shippingAddress, fulfillmentType: $fulfillmentType, appContext: $appContext, paymentMethod: $paymentMethod)';
}


}

/// @nodoc
abstract mixin class _$BuyProductRequestCopyWith<$Res> implements $BuyProductRequestCopyWith<$Res> {
  factory _$BuyProductRequestCopyWith(_BuyProductRequest value, $Res Function(_BuyProductRequest) _then) = __$BuyProductRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'product_id') String productId, int quantity,@JsonKey(name: 'shipping_address') ShippingAddress shippingAddress,@JsonKey(name: 'fulfillment_type') String fulfillmentType,@JsonKey(name: 'app_context') String? appContext,@JsonKey(name: 'payment_method') String? paymentMethod
});


@override $ShippingAddressCopyWith<$Res> get shippingAddress;

}
/// @nodoc
class __$BuyProductRequestCopyWithImpl<$Res>
    implements _$BuyProductRequestCopyWith<$Res> {
  __$BuyProductRequestCopyWithImpl(this._self, this._then);

  final _BuyProductRequest _self;
  final $Res Function(_BuyProductRequest) _then;

/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? quantity = null,Object? shippingAddress = null,Object? fulfillmentType = null,Object? appContext = freezed,Object? paymentMethod = freezed,}) {
  return _then(_BuyProductRequest(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,shippingAddress: null == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as ShippingAddress,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as String,appContext: freezed == appContext ? _self.appContext : appContext // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of BuyProductRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShippingAddressCopyWith<$Res> get shippingAddress {
  
  return $ShippingAddressCopyWith<$Res>(_self.shippingAddress, (value) {
    return _then(_self.copyWith(shippingAddress: value));
  });
}
}


/// @nodoc
mixin _$UpdateOrderStatusRequest {

 OrderStatus get status;
/// Create a copy of UpdateOrderStatusRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateOrderStatusRequestCopyWith<UpdateOrderStatusRequest> get copyWith => _$UpdateOrderStatusRequestCopyWithImpl<UpdateOrderStatusRequest>(this as UpdateOrderStatusRequest, _$identity);

  /// Serializes this UpdateOrderStatusRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateOrderStatusRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateOrderStatusRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class $UpdateOrderStatusRequestCopyWith<$Res>  {
  factory $UpdateOrderStatusRequestCopyWith(UpdateOrderStatusRequest value, $Res Function(UpdateOrderStatusRequest) _then) = _$UpdateOrderStatusRequestCopyWithImpl;
@useResult
$Res call({
 OrderStatus status
});




}
/// @nodoc
class _$UpdateOrderStatusRequestCopyWithImpl<$Res>
    implements $UpdateOrderStatusRequestCopyWith<$Res> {
  _$UpdateOrderStatusRequestCopyWithImpl(this._self, this._then);

  final UpdateOrderStatusRequest _self;
  final $Res Function(UpdateOrderStatusRequest) _then;

/// Create a copy of UpdateOrderStatusRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateOrderStatusRequest].
extension UpdateOrderStatusRequestPatterns on UpdateOrderStatusRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateOrderStatusRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateOrderStatusRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateOrderStatusRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderStatus status)  $default,) {final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderStatus status)?  $default,) {final _that = this;
switch (_that) {
case _UpdateOrderStatusRequest() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateOrderStatusRequest implements UpdateOrderStatusRequest {
  const _UpdateOrderStatusRequest({required this.status});
  factory _UpdateOrderStatusRequest.fromJson(Map<String, dynamic> json) => _$UpdateOrderStatusRequestFromJson(json);

@override final  OrderStatus status;

/// Create a copy of UpdateOrderStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateOrderStatusRequestCopyWith<_UpdateOrderStatusRequest> get copyWith => __$UpdateOrderStatusRequestCopyWithImpl<_UpdateOrderStatusRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateOrderStatusRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateOrderStatusRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateOrderStatusRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class _$UpdateOrderStatusRequestCopyWith<$Res> implements $UpdateOrderStatusRequestCopyWith<$Res> {
  factory _$UpdateOrderStatusRequestCopyWith(_UpdateOrderStatusRequest value, $Res Function(_UpdateOrderStatusRequest) _then) = __$UpdateOrderStatusRequestCopyWithImpl;
@override @useResult
$Res call({
 OrderStatus status
});




}
/// @nodoc
class __$UpdateOrderStatusRequestCopyWithImpl<$Res>
    implements _$UpdateOrderStatusRequestCopyWith<$Res> {
  __$UpdateOrderStatusRequestCopyWithImpl(this._self, this._then);

  final _UpdateOrderStatusRequest _self;
  final $Res Function(_UpdateOrderStatusRequest) _then;

/// Create a copy of UpdateOrderStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_UpdateOrderStatusRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,
  ));
}


}

// dart format on
