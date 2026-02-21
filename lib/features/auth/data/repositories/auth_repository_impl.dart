import 'package:injectable/injectable.dart';

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
  Future<void> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);
    await _tokenStorage.saveToken(response.token);
    // Ideally, we would also save the user model locally here.
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await _remoteDataSource.register(request);
    // Since registration doesn't return a token, we log in immediately after.
    final loginResponse = await _remoteDataSource.login(
      LoginRequest(
        phoneNumber: request.phoneNumber,
        password: request.password,
      ),
    );
    await _tokenStorage.saveToken(loginResponse.token);
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
    // Return the locally stored user model or fetch it using `/auth/me` if it exists on the backend.
    // For now, since login/register return the user, we would have saved it.
    // Returning null as a placeholder, would require local storage implementation for User.
    return null;
  }
}
