import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mustamal/core/services/log_service.dart';

import '../../../../core/network/api_constants.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(SendOtpRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<UserModel> getMe();
  Future<AuthResponse> registerWithPassword(PasswordRegisterRequest request);
  Future<AuthResponse> loginWithPassword(PasswordLoginRequest request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> sendOtp(SendOtpRequest request) async {
    await _dio.post(ApiConstants.sendOtp, data: request.toJson());
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    LogService().info('DEBUG: Registration response: ${response.data}');
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.usersMe);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> registerWithPassword(PasswordRegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.authRegisterPassword,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<AuthResponse> loginWithPassword(PasswordLoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.authLoginPassword,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
