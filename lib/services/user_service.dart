import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../utils/api.dart';

class UserService {
  static String get _base => '${Api.baseUrl}/api';

  Future<User> getMe(String token) async {
    final res = await http.get(
      Uri.parse('$_base/users/me'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Erreur profil');
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<User> updateMe(String token, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$_base/users/me'),
      headers: Api.authHeaders(token),
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Erreur mise à jour');
    }
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<User>> getSubscriptions(String token) async {
    final res = await http.get(
      Uri.parse('$_base/subscriptions'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List;
    return list.map((e) {
      final creator = e['creator'] as Map<String, dynamic>;
      return User(
        id: creator['userId'] as String,
        email: '',
        username: (creator['username'] ?? creator['displayName'] ?? '') as String,
        avatar: creator['avatar'] as String?,
      );
    }).toList();
  }

  /// Retourne les IDs des entités Creator (pour POST /api/posts?creatorId=)
  Future<List<String>> getRawSubscriptions(String token) async {
    final res = await http.get(
      Uri.parse('$_base/subscriptions'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => (e['creator'] as Map<String, dynamic>)['id'] as String)
        .toList();
  }

  Future<List<User>> search(String token, String query) async {
    final uri = Uri.parse('$_base/users/search').replace(
      queryParameters: {'q': query},
    );
    final res = await http.get(
      uri,
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  static MediaType _mimeFromFilename(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'gif' => MediaType('image', 'gif'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }

  Future<String> uploadAvatar(String token, List<int> bytes, String filename) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/upload'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        contentType: _mimeFromFilename(filename),
      ));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 201) throw Exception('Erreur upload');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['url'] as String;
  }
}
