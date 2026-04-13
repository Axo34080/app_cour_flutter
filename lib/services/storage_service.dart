import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  StorageService() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyToken = 'ov_token';
  static const _keyUser = 'ov_user';

  Future<void> saveAuth(String token, User user) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUser, value: jsonEncode(user.toJson())),
    ]);
  }

  Future<String?> readToken() => _storage.read(key: _keyToken);

  Future<User?> readUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyUser),
    ]);
  }
}
