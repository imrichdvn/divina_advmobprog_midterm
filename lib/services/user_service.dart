import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

class UserService {
  static final instance = UserService();
  final http.Client _client;
  User? currentUser;
  final Map<int, User> _users = {};

  UserService({http.Client? client}) : _client = client ?? http.Client();

  Future<User> login(String username, String password) async {
    final response = await _client
        .post(
          Uri.parse('$host/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'password': password,
            'expiresInMins': 60,
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 400 || response.statusCode == 401) {
      throw StateError('Please check your credentials and sign in again.');
    }
    final data = _decode(response);
    final user = User.fromJson(data);
    await _save(user, data);
    currentUser = user;
    return user;
  }

  Future<void> _save(User user, Map<String, dynamic> tokens) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      'session',
      jsonEncode({
        'user': user.toJson(),
        'accessToken': tokens['accessToken'],
        'refreshToken': tokens['refreshToken'],
      }),
    )) {
      throw StateError('Could not save your session.');
    }
  }

  Future<http.Response> _authUser(String token) => _client
      .get(
        Uri.parse('$host/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      )
      .timeout(const Duration(seconds: 20));

  Future<User?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session');
    if (raw == null) return null;
    Map<String, dynamic> session;
    try {
      session = jsonDecode(raw) as Map<String, dynamic>;
      User.fromJson(session['user'] as Map<String, dynamic>);
      if (session['accessToken'] is! String ||
          session['refreshToken'] is! String) {
        throw const FormatException('Invalid session');
      }
    } catch (_) {
      await signOut();
      return null;
    }

    var response = await _authUser(session['accessToken']);
    if ([401, 403].contains(response.statusCode)) {
      final refresh = await _client
          .post(
            Uri.parse('$host/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'refreshToken': session['refreshToken'],
              'expiresInMins': 60,
            }),
          )
          .timeout(const Duration(seconds: 20));
      if ([400, 401, 403].contains(refresh.statusCode)) {
        await signOut();
        return null;
      }
      session.addAll(_decode(refresh));
      response = await _authUser(session['accessToken']);
    }
    if ([400, 401, 403].contains(response.statusCode)) {
      await signOut();
      return null;
    }
    final user = User.fromJson(_decode(response));
    await _save(user, session);
    currentUser = user;
    return user;
  }

  Future<User> getUser(int id) async {
    if (currentUser?.id == id) return currentUser!;
    if (_users.containsKey(id)) return _users[id]!;
    final response = await _client
        .get(Uri.parse('$host/users/$id'))
        .timeout(const Duration(seconds: 20));
    final user = User.fromJson(_decode(response));
    _users[id] = user;
    return user;
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode != 200) {
      throw StateError(
        'Request failed (${response.statusCode}). Please retry.',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove('session')) {
      throw StateError('Could not clear your session.');
    }
    currentUser = null;
    _users.clear();
  }
}
