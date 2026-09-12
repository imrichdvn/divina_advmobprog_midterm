import 'dart:convert';
import 'package:http/http.dart';

import '../constants.dart';
import '../models/post.dart';

class PostService {
  final Client _client;
  PostService({Client? client}) : _client = client ?? Client();

  Future<List<Post>> getPostsByUser(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId?limit=0');
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    return (data['posts'] as List? ?? []).map((p) => Post.fromJson(p)).toList();
  }

  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    final response = await _client
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      return postsJson.map((p) => Post.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }
}
