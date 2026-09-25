import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class CommentService {
  final http.Client _client;
  CommentService({http.Client? client}) : _client = client ?? http.Client();

  String _key(int postId, int userId) => 'comments.$userId.$postId';

  Future<List<Comment>> getComments(int postId, int userId) async {
    var remote = <Comment>[];
    try {
      final response = await _client
          .get(Uri.parse('$host/comments/post/$postId?limit=0'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        remote = (data['comments'] as List? ?? [])
            .map((json) => Comment.fromJson(json))
            .toList();
      }
    } catch (_) {
      // Locally saved comments remain available when the demo API is offline.
    }
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_key(postId, userId)) ?? [];
    return [
      ...remote,
      ...local.map((raw) => Comment.fromJson(jsonDecode(raw))),
    ];
  }

  Future<Comment> addComment(int postId, User user, String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) throw ArgumentError('Enter a comment.');
    try {
      await _client
          .post(
            Uri.parse('$host/comments/add'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'postId': postId,
              'userId': user.id,
              'body': trimmed,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      // DummyJSON is best-effort; the local comment is the durable copy.
    }

    final comment = Comment(
      id: -DateTime.now().microsecondsSinceEpoch,
      postId: postId,
      userId: user.id,
      userName: user.fullName,
      body: trimmed,
    );
    final prefs = await SharedPreferences.getInstance();
    final key = _key(postId, user.id);
    final saved = [...prefs.getStringList(key) ?? <String>[]];
    saved.add(jsonEncode(comment.toJson()));
    if (!await prefs.setStringList(key, saved)) {
      throw StateError('Could not save your comment.');
    }
    return comment;
  }
}
