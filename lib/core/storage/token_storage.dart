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

  // iOS Keychain accessibility fix: use first_unlock_this_device so reads
  // succeed even when the device was just booted and the screen hasn't been
  // unlocked yet. Without this, secure_storage can deadlock on iOS.
  static const _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  TokenStorageImpl() : _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(
      key: _keyToken,
      value: token,
      iOptions: _iosOptions,
    );
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken, iOptions: _iosOptions);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken, iOptions: _iosOptions);
  }
}
