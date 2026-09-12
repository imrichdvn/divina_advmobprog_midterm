import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cando_mobprog/models/user.dart';
import 'package:cando_mobprog/services/user_service.dart';
import 'package:cando_mobprog/services/post_service.dart';
import 'package:cando_mobprog/services/comment_service.dart';
import 'package:cando_mobprog/services/preferences_service.dart';

const userJson = {
  'id': 1,
  'username': 'emilys',
  'firstName': 'Emily',
  'lastName': 'Johnson',
  'email': 'emily@example.com',
  'image': '',
};

http.Response jsonResponse(Object data, [int status = 200]) =>
    http.Response(jsonEncode(data), status);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'login saves user and tokens, never password; sign-out removes session',
    () async {
      final service = UserService(
        client: MockClient((request) async {
          expect(request.url.path, '/auth/login');
          expect(jsonDecode(request.body)['password'], 'password');
          return jsonResponse({
            ...userJson,
            'accessToken': 'access',
            'refreshToken': 'refresh',
          });
        }),
      );
      final user = await service.login('emilys', 'password');
      expect(user.fullName, 'Emily Johnson');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('session'), isNot(contains('password')));
      expect(jsonDecode(prefs.getString('session')!)['user']['id'], 1);
      await prefs.setString('themeMode', 'dark');
      await service.signOut();
      expect(service.currentUser, isNull);
      expect(prefs.getString('session'), isNull);
      expect(prefs.getString('themeMode'), 'dark');
    },
  );

  test('invalid login does not create a session', () async {
    final service = UserService(
      client: MockClient(
        (_) async => jsonResponse({'message': 'Invalid credentials'}, 400),
      ),
    );
    await expectLater(service.login('wrong', 'wrong'), throwsStateError);
    expect(
      (await SharedPreferences.getInstance()).getString('session'),
      isNull,
    );
  });

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'session',
      jsonEncode({
        'user': userJson,
        'accessToken': 'expired',
        'refreshToken': 'refresh',
      }),
    );
  }

  test(
    'startup refreshes expired access token and saves replacement',
    () async {
      await saveSession();
      final requests = <String>[];
      final service = UserService(
        client: MockClient((request) async {
          requests.add(request.url.path);
          if (request.url.path == '/auth/refresh') {
            expect(jsonDecode(request.body)['refreshToken'], 'refresh');
            return jsonResponse({'accessToken': 'new', 'refreshToken': 'next'});
          }
          if (request.headers['Authorization'] == 'Bearer expired') {
            return jsonResponse({}, 401);
          }
          expect(request.headers['Authorization'], 'Bearer new');
          return jsonResponse(userJson);
        }),
      );
      expect((await service.restoreSession())?.id, 1);
      expect(requests, ['/auth/me', '/auth/refresh', '/auth/me']);
      final saved = (await SharedPreferences.getInstance()).getString(
        'session',
      )!;
      expect(jsonDecode(saved)['accessToken'], 'new');
    },
  );

  test(
    'rejected refresh clears session; network failure preserves it for retry',
    () async {
      await saveSession();
      final rejected = UserService(
        client: MockClient((_) async => jsonResponse({}, 401)),
      );
      expect(await rejected.restoreSession(), isNull);
      expect(
        (await SharedPreferences.getInstance()).getString('session'),
        isNull,
      );
      await saveSession();
      final offline = UserService(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      await expectLater(
        offline.restoreSession(),
        throwsA(isA<http.ClientException>()),
      );
      expect(
        (await SharedPreferences.getInstance()).getString('session'),
        isNotNull,
      );
    },
  );

  test('missing or malformed saved session returns logged-out state', () async {
    final service = UserService();
    expect(await service.restoreSession(), isNull);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session', '{invalid');
    expect(await service.restoreSession(), isNull);
    expect(prefs.getString('session'), isNull);
  });

  test('profile requests posts by user ID; feed sends pagination', () async {
    final paths = <String>[];
    final service = PostService(
      client: MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path == '/posts') {
          expect(request.url.queryParameters, {'limit': '10', 'skip': '30'});
        } else {
          expect(request.url.queryParameters['limit'], '0');
        }
        return jsonResponse({
          'posts': [
            {
              'id': 8,
              'userId': 5,
              'body': 'A post',
              'reactions': {'likes': 2, 'dislikes': 0},
            },
          ],
        });
      }),
    );
    expect((await service.getPostsByUser(5)).single.userId, 5);
    expect((await service.getPosts(limit: 10, skip: 30)).single.id, 8);
    expect(paths, ['/posts/user/5', '/posts']);
  });

  test(
    'comments survive refetch with distinct local IDs and account isolation',
    () async {
      final user = User.fromJson(userJson);
      final service = CommentService(
        client: MockClient((request) async {
          if (request.method == 'POST') {
            expect(jsonDecode(request.body), {
              'postId': 8,
              'userId': 1,
              'body': 'Hello',
            });
            return jsonResponse({'id': 341}, 201);
          }
          expect(request.url.path, '/comments/post/8');
          expect(request.url.queryParameters['limit'], '0');
          return jsonResponse({
            'comments': [
              {
                'id': 1,
                'postId': 8,
                'body': 'Existing',
                'likes': 3,
                'user': {'id': 2, 'username': 'sam'},
              },
            ],
          });
        }),
      );
      final first = await service.addComment(8, user, ' Hello ');
      final second = await service.addComment(8, user, 'Hello');
      expect(first.id, isNot(second.id));
      expect((await service.getComments(8, 1)).map((c) => c.body), [
        'Existing',
        'Hello',
        'Hello',
      ]);
      expect((await service.getComments(8, 2)).length, 1);
      await expectLater(service.addComment(8, user, '  '), throwsArgumentError);
    },
  );

  test('failed comment request does not save a local comment', () async {
    final service = CommentService(
      client: MockClient((_) async => jsonResponse({}, 500)),
    );
    await expectLater(
      service.addComment(8, User.fromJson(userJson), 'Hello'),
      throwsStateError,
    );
    expect(
      (await SharedPreferences.getInstance()).getStringList('comments.1.8'),
      isNull,
    );
  });

  test('likes toggle, persist, and remain isolated between accounts', () async {
    final service = PreferencesService();
    await service.loadLikes(1);
    await service.toggleLike('post.8');
    expect(service.isLiked('post.8'), isTrue);
    await service.loadLikes(2);
    expect(service.isLiked('post.8'), isFalse);
    await service.loadLikes(1);
    expect(service.isLiked('post.8'), isTrue);
    await service.toggleLike('post.8');
    await service.loadLikes(1);
    expect(service.isLiked('post.8'), isFalse);
    service.dispose();
  });

  test('theme preference restores across service instances', () async {
    final service = PreferencesService();
    await service.setTheme(ThemeMode.dark);
    final restored = PreferencesService();
    await restored.load();
    expect(restored.themeMode.value, ThemeMode.dark);
  });
}
