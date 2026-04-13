import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  StorageService();

  static const _keyToken = 'ov_token';
  static const _keyUser = 'ov_user';

  // Mobile : stockage chiffré
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAuth(String token, User user) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } else {
      await Future.wait([
        _secure.write(key: _keyToken, value: token),
        _secure.write(key: _keyUser, value: jsonEncode(user.toJson())),
      ]);
    }
  }

  Future<String?> readToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    }
    return _secure.read(key: _keyToken);
  }

  Future<User?> readUser() async {
    String? raw;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      raw = prefs.getString(_keyUser);
    } else {
      raw = await _secure.read(key: _keyUser);
    }
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } else {
      await Future.wait([
        _secure.delete(key: _keyToken),
        _secure.delete(key: _keyUser),
      ]);
    }
  }
}
