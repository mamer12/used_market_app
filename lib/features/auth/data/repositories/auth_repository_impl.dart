import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<void> sendOtp(SendOtpRequest request) async {
    await _remoteDataSource.sendOtp(request);
  }

  @override
  Future<void> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);
    await _tokenStorage.saveToken(response.token!);
    // Ideally, we would also save the user model locally here.
  }

  @override
  Future<void> register(RegisterRequest request) async {
    final response = await _remoteDataSource.register(request);
    final token = response.token;

    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    } else {
      throw ApiException(
        'Account created! Please log in with a new code.',
        statusCode: 201, // Indicate success of creation but need login
      );
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return await _remoteDataSource.getMe();
    } catch (_) {
      return null;
    }
  }
}
