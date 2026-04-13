import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';

class CallService {
  Future<String> createRoom(String token) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/api/video/room'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode != 201) throw Exception('Impossible de créer la salle');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['url'] as String;
  }
}
