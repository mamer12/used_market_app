import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_constants.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<void> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> register(RegisterRequest request) async {
    await _dio.post(ApiConstants.register, data: request.toJson());
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
