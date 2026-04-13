import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../utils/api.dart';

class PostService {
  static String get _base => '${Api.baseUrl}/api';

  /// Récupère les posts d'un seul créateur (déjà débloqués si abonné).
  Future<List<Post>> getPostsByCreator(String token, String creatorId) async {
    final uri = Uri.parse('$_base/posts').replace(
      queryParameters: {'creatorId': creatorId},
    );
    final res = await http.get(uri, headers: Api.authHeaders(token))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return [];
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Récupère les posts de tous les créateurs suivis en parallèle,
  /// puis les trie du plus récent au plus ancien.
  Future<List<Post>> getFeed(String token, List<String> creatorIds) async {
    if (creatorIds.isEmpty) return [];
    final results = await Future.wait(
      creatorIds.map((id) => getPostsByCreator(token, id)),
    );
    final all = results.expand((posts) => posts).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }
}
