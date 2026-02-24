// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SendOtpRequest {

@JsonKey(name: 'phone_number') String get phoneNumber;
/// Create a copy of SendOtpRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SendOtpRequestCopyWith<SendOtpRequest> get copyWith => _$SendOtpRequestCopyWithImpl<SendOtpRequest>(this as SendOtpRequest, _$identity);

  /// Serializes this SendOtpRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SendOtpRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber);

@override
String toString() {
  return 'SendOtpRequest(phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $SendOtpRequestCopyWith<$Res>  {
  factory $SendOtpRequestCopyWith(SendOtpRequest value, $Res Function(SendOtpRequest) _then) = _$SendOtpRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber
});




}
/// @nodoc
class _$SendOtpRequestCopyWithImpl<$Res>
    implements $SendOtpRequestCopyWith<$Res> {
  _$SendOtpRequestCopyWithImpl(this._self, this._then);

  final SendOtpRequest _self;
  final $Res Function(SendOtpRequest) _then;

/// Create a copy of SendOtpRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = null,}) {
  return _then(_self.copyWith(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SendOtpRequest].
extension SendOtpRequestPatterns on SendOtpRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SendOtpRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SendOtpRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SendOtpRequest value)  $default,){
final _that = this;
switch (_that) {
case _SendOtpRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SendOtpRequest value)?  $default,){
final _that = this;
switch (_that) {
case _SendOtpRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SendOtpRequest() when $default != null:
return $default(_that.phoneNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber)  $default,) {final _that = this;
switch (_that) {
case _SendOtpRequest():
return $default(_that.phoneNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'phone_number')  String phoneNumber)?  $default,) {final _that = this;
switch (_that) {
case _SendOtpRequest() when $default != null:
return $default(_that.phoneNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SendOtpRequest implements SendOtpRequest {
  const _SendOtpRequest({@JsonKey(name: 'phone_number') required this.phoneNumber});
  factory _SendOtpRequest.fromJson(Map<String, dynamic> json) => _$SendOtpRequestFromJson(json);

@override@JsonKey(name: 'phone_number') final  String phoneNumber;

/// Create a copy of SendOtpRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendOtpRequestCopyWith<_SendOtpRequest> get copyWith => __$SendOtpRequestCopyWithImpl<_SendOtpRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SendOtpRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendOtpRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber);

@override
String toString() {
  return 'SendOtpRequest(phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class _$SendOtpRequestCopyWith<$Res> implements $SendOtpRequestCopyWith<$Res> {
  factory _$SendOtpRequestCopyWith(_SendOtpRequest value, $Res Function(_SendOtpRequest) _then) = __$SendOtpRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber
});




}
/// @nodoc
class __$SendOtpRequestCopyWithImpl<$Res>
    implements _$SendOtpRequestCopyWith<$Res> {
  __$SendOtpRequestCopyWithImpl(this._self, this._then);

  final _SendOtpRequest _self;
  final $Res Function(_SendOtpRequest) _then;

/// Create a copy of SendOtpRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,}) {
  return _then(_SendOtpRequest(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RegisterRequest {

@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'phone_number') String get phoneNumber; String get otp;
/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegisterRequestCopyWith<RegisterRequest> get copyWith => _$RegisterRequestCopyWithImpl<RegisterRequest>(this as RegisterRequest, _$identity);

  /// Serializes this RegisterRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,otp);

@override
String toString() {
  return 'RegisterRequest(fullName: $fullName, phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class $RegisterRequestCopyWith<$Res>  {
  factory $RegisterRequestCopyWith(RegisterRequest value, $Res Function(RegisterRequest) _then) = _$RegisterRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class _$RegisterRequestCopyWithImpl<$Res>
    implements $RegisterRequestCopyWith<$Res> {
  _$RegisterRequestCopyWithImpl(this._self, this._then);

  final RegisterRequest _self;
  final $Res Function(RegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RegisterRequest].
extension RegisterRequestPatterns on RegisterRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegisterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegisterRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegisterRequest value)  $default,){
final _that = this;
switch (_that) {
case _RegisterRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegisterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _RegisterRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegisterRequest() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)  $default,) {final _that = this;
switch (_that) {
case _RegisterRequest():
return $default(_that.fullName,_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,) {final _that = this;
switch (_that) {
case _RegisterRequest() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.otp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RegisterRequest implements RegisterRequest {
  const _RegisterRequest({@JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'phone_number') required this.phoneNumber, required this.otp});
  factory _RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String otp;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegisterRequestCopyWith<_RegisterRequest> get copyWith => __$RegisterRequestCopyWithImpl<_RegisterRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegisterRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,otp);

@override
String toString() {
  return 'RegisterRequest(fullName: $fullName, phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class _$RegisterRequestCopyWith<$Res> implements $RegisterRequestCopyWith<$Res> {
  factory _$RegisterRequestCopyWith(_RegisterRequest value, $Res Function(_RegisterRequest) _then) = __$RegisterRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class __$RegisterRequestCopyWithImpl<$Res>
    implements _$RegisterRequestCopyWith<$Res> {
  __$RegisterRequestCopyWithImpl(this._self, this._then);

  final _RegisterRequest _self;
  final $Res Function(_RegisterRequest) _then;

/// Create a copy of RegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_RegisterRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoginRequest {

@JsonKey(name: 'phone_number') String get phoneNumber; String get otp;
/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginRequestCopyWith<LoginRequest> get copyWith => _$LoginRequestCopyWithImpl<LoginRequest>(this as LoginRequest, _$identity);

  /// Serializes this LoginRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,otp);

@override
String toString() {
  return 'LoginRequest(phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class $LoginRequestCopyWith<$Res>  {
  factory $LoginRequestCopyWith(LoginRequest value, $Res Function(LoginRequest) _then) = _$LoginRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class _$LoginRequestCopyWithImpl<$Res>
    implements $LoginRequestCopyWith<$Res> {
  _$LoginRequestCopyWithImpl(this._self, this._then);

  final LoginRequest _self;
  final $Res Function(LoginRequest) _then;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_self.copyWith(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginRequest].
extension LoginRequestPatterns on LoginRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginRequest value)  $default,){
final _that = this;
switch (_that) {
case _LoginRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginRequest value)?  $default,){
final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
return $default(_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String otp)  $default,) {final _that = this;
switch (_that) {
case _LoginRequest():
return $default(_that.phoneNumber,_that.otp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String otp)?  $default,) {final _that = this;
switch (_that) {
case _LoginRequest() when $default != null:
return $default(_that.phoneNumber,_that.otp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginRequest implements LoginRequest {
  const _LoginRequest({@JsonKey(name: 'phone_number') required this.phoneNumber, required this.otp});
  factory _LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String otp;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginRequestCopyWith<_LoginRequest> get copyWith => __$LoginRequestCopyWithImpl<_LoginRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,otp);

@override
String toString() {
  return 'LoginRequest(phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class _$LoginRequestCopyWith<$Res> implements $LoginRequestCopyWith<$Res> {
  factory _$LoginRequestCopyWith(_LoginRequest value, $Res Function(_LoginRequest) _then) = __$LoginRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber, String otp
});




}
/// @nodoc
class __$LoginRequestCopyWithImpl<$Res>
    implements _$LoginRequestCopyWith<$Res> {
  __$LoginRequestCopyWithImpl(this._self, this._then);

  final _LoginRequest _self;
  final $Res Function(_LoginRequest) _then;

/// Create a copy of LoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_LoginRequest(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,otp: null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserModel {

 String? get id;@JsonKey(name: 'full_name') String? get fullName;@JsonKey(name: 'phone_number') String? get phoneNumber; String get role;@JsonKey(name: 'is_verified') bool get isVerified;@JsonKey(name: 'strikes_count') int get strikesCount;@JsonKey(name: 'is_banned') bool get isBanned;@JsonKey(name: 'wallet_balance') String get walletBalance;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.strikesCount, strikesCount) || other.strikesCount == strikesCount)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,role,isVerified,strikesCount,isBanned,walletBalance,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, role: $role, isVerified: $isVerified, strikesCount: $strikesCount, isBanned: $isBanned, walletBalance: $walletBalance, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'phone_number') String? phoneNumber, String role,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'strikes_count') int strikesCount,@JsonKey(name: 'is_banned') bool isBanned,@JsonKey(name: 'wallet_balance') String walletBalance,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? fullName = freezed,Object? phoneNumber = freezed,Object? role = null,Object? isVerified = null,Object? strikesCount = null,Object? isBanned = null,Object? walletBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,strikesCount: null == strikesCount ? _self.strikesCount : strikesCount // ignore: cast_nullable_to_non_nullable
as int,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'phone_number')  String? phoneNumber,  String role, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'strikes_count')  int strikesCount, @JsonKey(name: 'is_banned')  bool isBanned, @JsonKey(name: 'wallet_balance')  String walletBalance, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.role,_that.isVerified,_that.strikesCount,_that.isBanned,_that.walletBalance,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'phone_number')  String? phoneNumber,  String role, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'strikes_count')  int strikesCount, @JsonKey(name: 'is_banned')  bool isBanned, @JsonKey(name: 'wallet_balance')  String walletBalance, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.role,_that.isVerified,_that.strikesCount,_that.isBanned,_that.walletBalance,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'full_name')  String? fullName, @JsonKey(name: 'phone_number')  String? phoneNumber,  String role, @JsonKey(name: 'is_verified')  bool isVerified, @JsonKey(name: 'strikes_count')  int strikesCount, @JsonKey(name: 'is_banned')  bool isBanned, @JsonKey(name: 'wallet_balance')  String walletBalance, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.role,_that.isVerified,_that.strikesCount,_that.isBanned,_that.walletBalance,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({this.id, @JsonKey(name: 'full_name') this.fullName, @JsonKey(name: 'phone_number') this.phoneNumber, this.role = 'user', @JsonKey(name: 'is_verified') this.isVerified = false, @JsonKey(name: 'strikes_count') this.strikesCount = 0, @JsonKey(name: 'is_banned') this.isBanned = false, @JsonKey(name: 'wallet_balance') this.walletBalance = '0', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'full_name') final  String? fullName;
@override@JsonKey(name: 'phone_number') final  String? phoneNumber;
@override@JsonKey() final  String role;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey(name: 'strikes_count') final  int strikesCount;
@override@JsonKey(name: 'is_banned') final  bool isBanned;
@override@JsonKey(name: 'wallet_balance') final  String walletBalance;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.role, role) || other.role == role)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.strikesCount, strikesCount) || other.strikesCount == strikesCount)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,role,isVerified,strikesCount,isBanned,walletBalance,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, role: $role, isVerified: $isVerified, strikesCount: $strikesCount, isBanned: $isBanned, walletBalance: $walletBalance, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'full_name') String? fullName,@JsonKey(name: 'phone_number') String? phoneNumber, String role,@JsonKey(name: 'is_verified') bool isVerified,@JsonKey(name: 'strikes_count') int strikesCount,@JsonKey(name: 'is_banned') bool isBanned,@JsonKey(name: 'wallet_balance') String walletBalance,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? fullName = freezed,Object? phoneNumber = freezed,Object? role = null,Object? isVerified = null,Object? strikesCount = null,Object? isBanned = null,Object? walletBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,strikesCount: null == strikesCount ? _self.strikesCount : strikesCount // ignore: cast_nullable_to_non_nullable
as int,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,walletBalance: null == walletBalance ? _self.walletBalance : walletBalance // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AuthResponse {

 String? get token; UserModel get user;
/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthResponseCopyWith<AuthResponse> get copyWith => _$AuthResponseCopyWithImpl<AuthResponse>(this as AuthResponse, _$identity);

  /// Serializes this AuthResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,user);

@override
String toString() {
  return 'AuthResponse(token: $token, user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthResponseCopyWith<$Res>  {
  factory $AuthResponseCopyWith(AuthResponse value, $Res Function(AuthResponse) _then) = _$AuthResponseCopyWithImpl;
@useResult
$Res call({
 String? token, UserModel user
});


$UserModelCopyWith<$Res> get user;

}
/// @nodoc
class _$AuthResponseCopyWithImpl<$Res>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._self, this._then);

  final AuthResponse _self;
  final $Res Function(AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = freezed,Object? user = null,}) {
  return _then(_self.copyWith(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}
/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthResponse].
extension AuthResponsePatterns on AuthResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthResponse value)  $default,){
final _that = this;
switch (_that) {
case _AuthResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthResponse value)?  $default,){
final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? token,  UserModel user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.token,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? token,  UserModel user)  $default,) {final _that = this;
switch (_that) {
case _AuthResponse():
return $default(_that.token,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? token,  UserModel user)?  $default,) {final _that = this;
switch (_that) {
case _AuthResponse() when $default != null:
return $default(_that.token,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthResponse implements AuthResponse {
  const _AuthResponse({this.token, required this.user});
  factory _AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

@override final  String? token;
@override final  UserModel user;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthResponseCopyWith<_AuthResponse> get copyWith => __$AuthResponseCopyWithImpl<_AuthResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthResponse&&(identical(other.token, token) || other.token == token)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,user);

@override
String toString() {
  return 'AuthResponse(token: $token, user: $user)';
}


}

/// @nodoc
abstract mixin class _$AuthResponseCopyWith<$Res> implements $AuthResponseCopyWith<$Res> {
  factory _$AuthResponseCopyWith(_AuthResponse value, $Res Function(_AuthResponse) _then) = __$AuthResponseCopyWithImpl;
@override @useResult
$Res call({
 String? token, UserModel user
});


@override $UserModelCopyWith<$Res> get user;

}
/// @nodoc
class __$AuthResponseCopyWithImpl<$Res>
    implements _$AuthResponseCopyWith<$Res> {
  __$AuthResponseCopyWithImpl(this._self, this._then);

  final _AuthResponse _self;
  final $Res Function(_AuthResponse) _then;

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = freezed,Object? user = null,}) {
  return _then(_AuthResponse(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,
  ));
}

/// Create a copy of AuthResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserModelCopyWith<$Res> get user {
  
  return $UserModelCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$PasswordRegisterRequest {

@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'phone_number') String get phoneNumber; String get password;
/// Create a copy of PasswordRegisterRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordRegisterRequestCopyWith<PasswordRegisterRequest> get copyWith => _$PasswordRegisterRequestCopyWithImpl<PasswordRegisterRequest>(this as PasswordRegisterRequest, _$identity);

  /// Serializes this PasswordRegisterRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordRegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,password);

@override
String toString() {
  return 'PasswordRegisterRequest(fullName: $fullName, phoneNumber: $phoneNumber, password: $password)';
}


}

/// @nodoc
abstract mixin class $PasswordRegisterRequestCopyWith<$Res>  {
  factory $PasswordRegisterRequestCopyWith(PasswordRegisterRequest value, $Res Function(PasswordRegisterRequest) _then) = _$PasswordRegisterRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String password
});




}
/// @nodoc
class _$PasswordRegisterRequestCopyWithImpl<$Res>
    implements $PasswordRegisterRequestCopyWith<$Res> {
  _$PasswordRegisterRequestCopyWithImpl(this._self, this._then);

  final PasswordRegisterRequest _self;
  final $Res Function(PasswordRegisterRequest) _then;

/// Create a copy of PasswordRegisterRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fullName = null,Object? phoneNumber = null,Object? password = null,}) {
  return _then(_self.copyWith(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordRegisterRequest].
extension PasswordRegisterRequestPatterns on PasswordRegisterRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordRegisterRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordRegisterRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordRegisterRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordRegisterRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordRegisterRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordRegisterRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordRegisterRequest() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String password)  $default,) {final _that = this;
switch (_that) {
case _PasswordRegisterRequest():
return $default(_that.fullName,_that.phoneNumber,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'phone_number')  String phoneNumber,  String password)?  $default,) {final _that = this;
switch (_that) {
case _PasswordRegisterRequest() when $default != null:
return $default(_that.fullName,_that.phoneNumber,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordRegisterRequest implements PasswordRegisterRequest {
  const _PasswordRegisterRequest({@JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'phone_number') required this.phoneNumber, required this.password});
  factory _PasswordRegisterRequest.fromJson(Map<String, dynamic> json) => _$PasswordRegisterRequestFromJson(json);

@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String password;

/// Create a copy of PasswordRegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordRegisterRequestCopyWith<_PasswordRegisterRequest> get copyWith => __$PasswordRegisterRequestCopyWithImpl<_PasswordRegisterRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordRegisterRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordRegisterRequest&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fullName,phoneNumber,password);

@override
String toString() {
  return 'PasswordRegisterRequest(fullName: $fullName, phoneNumber: $phoneNumber, password: $password)';
}


}

/// @nodoc
abstract mixin class _$PasswordRegisterRequestCopyWith<$Res> implements $PasswordRegisterRequestCopyWith<$Res> {
  factory _$PasswordRegisterRequestCopyWith(_PasswordRegisterRequest value, $Res Function(_PasswordRegisterRequest) _then) = __$PasswordRegisterRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'phone_number') String phoneNumber, String password
});




}
/// @nodoc
class __$PasswordRegisterRequestCopyWithImpl<$Res>
    implements _$PasswordRegisterRequestCopyWith<$Res> {
  __$PasswordRegisterRequestCopyWithImpl(this._self, this._then);

  final _PasswordRegisterRequest _self;
  final $Res Function(_PasswordRegisterRequest) _then;

/// Create a copy of PasswordRegisterRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fullName = null,Object? phoneNumber = null,Object? password = null,}) {
  return _then(_PasswordRegisterRequest(
fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PasswordLoginRequest {

@JsonKey(name: 'phone_number') String get phoneNumber; String get password;
/// Create a copy of PasswordLoginRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordLoginRequestCopyWith<PasswordLoginRequest> get copyWith => _$PasswordLoginRequestCopyWithImpl<PasswordLoginRequest>(this as PasswordLoginRequest, _$identity);

  /// Serializes this PasswordLoginRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordLoginRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,password);

@override
String toString() {
  return 'PasswordLoginRequest(phoneNumber: $phoneNumber, password: $password)';
}


}

/// @nodoc
abstract mixin class $PasswordLoginRequestCopyWith<$Res>  {
  factory $PasswordLoginRequestCopyWith(PasswordLoginRequest value, $Res Function(PasswordLoginRequest) _then) = _$PasswordLoginRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber, String password
});




}
/// @nodoc
class _$PasswordLoginRequestCopyWithImpl<$Res>
    implements $PasswordLoginRequestCopyWith<$Res> {
  _$PasswordLoginRequestCopyWithImpl(this._self, this._then);

  final PasswordLoginRequest _self;
  final $Res Function(PasswordLoginRequest) _then;

/// Create a copy of PasswordLoginRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phoneNumber = null,Object? password = null,}) {
  return _then(_self.copyWith(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PasswordLoginRequest].
extension PasswordLoginRequestPatterns on PasswordLoginRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PasswordLoginRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PasswordLoginRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PasswordLoginRequest value)  $default,){
final _that = this;
switch (_that) {
case _PasswordLoginRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PasswordLoginRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PasswordLoginRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PasswordLoginRequest() when $default != null:
return $default(_that.phoneNumber,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String password)  $default,) {final _that = this;
switch (_that) {
case _PasswordLoginRequest():
return $default(_that.phoneNumber,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'phone_number')  String phoneNumber,  String password)?  $default,) {final _that = this;
switch (_that) {
case _PasswordLoginRequest() when $default != null:
return $default(_that.phoneNumber,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PasswordLoginRequest implements PasswordLoginRequest {
  const _PasswordLoginRequest({@JsonKey(name: 'phone_number') required this.phoneNumber, required this.password});
  factory _PasswordLoginRequest.fromJson(Map<String, dynamic> json) => _$PasswordLoginRequestFromJson(json);

@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override final  String password;

/// Create a copy of PasswordLoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PasswordLoginRequestCopyWith<_PasswordLoginRequest> get copyWith => __$PasswordLoginRequestCopyWithImpl<_PasswordLoginRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PasswordLoginRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PasswordLoginRequest&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,phoneNumber,password);

@override
String toString() {
  return 'PasswordLoginRequest(phoneNumber: $phoneNumber, password: $password)';
}


}

/// @nodoc
abstract mixin class _$PasswordLoginRequestCopyWith<$Res> implements $PasswordLoginRequestCopyWith<$Res> {
  factory _$PasswordLoginRequestCopyWith(_PasswordLoginRequest value, $Res Function(_PasswordLoginRequest) _then) = __$PasswordLoginRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'phone_number') String phoneNumber, String password
});




}
/// @nodoc
class __$PasswordLoginRequestCopyWithImpl<$Res>
    implements _$PasswordLoginRequestCopyWith<$Res> {
  __$PasswordLoginRequestCopyWithImpl(this._self, this._then);

  final _PasswordLoginRequest _self;
  final $Res Function(_PasswordLoginRequest) _then;

/// Create a copy of PasswordLoginRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? password = null,}) {
  return _then(_PasswordLoginRequest(
phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
