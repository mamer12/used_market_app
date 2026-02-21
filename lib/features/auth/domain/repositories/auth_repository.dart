import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getUser();
}
