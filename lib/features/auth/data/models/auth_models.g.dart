// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SendOtpRequest _$SendOtpRequestFromJson(Map<String, dynamic> json) =>
    _SendOtpRequest(phoneNumber: json['phone_number'] as String);

Map<String, dynamic> _$SendOtpRequestToJson(_SendOtpRequest instance) =>
    <String, dynamic>{'phone_number': instance.phoneNumber};

_RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    _RegisterRequest(
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(_RegisterRequest instance) =>
    <String, dynamic>{
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'otp': instance.otp,
    };

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      phoneNumber: json['phone_number'] as String,
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'otp': instance.otp,
    };

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String?,
  fullName: json['full_name'] as String?,
  phoneNumber: json['phone_number'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
    };

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      token: json['token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};
