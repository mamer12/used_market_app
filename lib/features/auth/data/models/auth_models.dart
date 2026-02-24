import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class SendOtpRequest with _$SendOtpRequest {
  const factory SendOtpRequest({
    @JsonKey(name: 'phone_number') required String phoneNumber,
  }) = _SendOtpRequest;

  factory SendOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestFromJson(json);
}

@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String otp,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String otp,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    String? id,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @Default('user') String role,
    @JsonKey(name: 'is_verified') @Default(false) bool isVerified,
    @JsonKey(name: 'strikes_count') @Default(0) int strikesCount,
    @JsonKey(name: 'is_banned') @Default(false) bool isBanned,
    @JsonKey(name: 'wallet_balance') @Default('0') String walletBalance,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({String? token, required UserModel user}) =
      _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

// ── Password-based auth ────────────────────────────────────────────────────────────

@freezed
abstract class PasswordRegisterRequest with _$PasswordRegisterRequest {
  const factory PasswordRegisterRequest({
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String password,
  }) = _PasswordRegisterRequest;

  factory PasswordRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordRegisterRequestFromJson(json);
}

@freezed
abstract class PasswordLoginRequest with _$PasswordLoginRequest {
  const factory PasswordLoginRequest({
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String password,
  }) = _PasswordLoginRequest;

  factory PasswordLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordLoginRequestFromJson(json);
}
