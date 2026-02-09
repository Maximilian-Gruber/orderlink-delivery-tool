import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<String?> getToken() =>
      _storage.read(key: 'access_token');

  Future<void> clear() => _storage.deleteAll();
}
