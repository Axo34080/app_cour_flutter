import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/api.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  static String get _baseUrl => '${Api.baseUrl}/api';

  Future<({String token, User user})> login(String email, String password) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    return _parseAuthResponse(res);
  }

  Future<({String token, User user})> signup(
    String email,
    String username,
    String password,
  ) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'username': username, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));

    return _parseAuthResponse(res);
  }

  ({String token, User user}) _parseAuthResponse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode >= 400) {
      final message = body['message'];
      throw AuthException(
        message is List ? message.join(', ') : message as String? ?? 'Erreur inconnue',
      );
    }

    return (
      token: body['access_token'] as String,
      user: User.fromJson(body['user'] as Map<String, dynamic>),
    );
  }
}
