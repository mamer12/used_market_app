import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

@LazySingleton(as: TokenStorage)
class TokenStorageImpl implements TokenStorage {
  static const _keyToken = 'jwt_token';
  final FlutterSecureStorage _secureStorage;

  TokenStorageImpl() : _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }
}
