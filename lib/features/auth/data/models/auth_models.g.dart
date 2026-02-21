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
  role: json['role'] as String? ?? 'user',
  isVerified: json['is_verified'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'role': instance.role,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      token: json['token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};

_PasswordRegisterRequest _$PasswordRegisterRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordRegisterRequest(
  fullName: json['full_name'] as String,
  phoneNumber: json['phone_number'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$PasswordRegisterRequestToJson(
  _PasswordRegisterRequest instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'password': instance.password,
};

_PasswordLoginRequest _$PasswordLoginRequestFromJson(
  Map<String, dynamic> json,
) => _PasswordLoginRequest(
  phoneNumber: json['phone_number'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$PasswordLoginRequestToJson(
  _PasswordLoginRequest instance,
) => <String, dynamic>{
  'phone_number': instance.phoneNumber,
  'password': instance.password,
};
