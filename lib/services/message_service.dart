import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/message.dart';
import '../utils/api.dart';

class MessageService {
  static String get _base => '${Api.baseUrl}/api/messages';

  Future<List<Conversation>> getConversations(String token) async {
    final res = await http.get(
      Uri.parse('$_base/conversations'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception('Erreur chargement conversations');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Message>> getHistory(String token, String userId) async {
    final res = await http.get(
      Uri.parse('$_base/$userId'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception('Erreur chargement messages');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(String token, String userId) async {
    await http.patch(
      Uri.parse('$_base/$userId/read'),
      headers: Api.authHeaders(token),
    ).timeout(const Duration(seconds: 5));
  }
}
