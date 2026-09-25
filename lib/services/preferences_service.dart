import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  static final instance = PreferencesService();
  final themeMode = ValueNotifier(ThemeMode.system);
  Set<String> _liked = {};
  String? _likesKey;
  bool savingLike = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('themeMode');
    final resolved = ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.light,
    );
    themeMode.value = resolved;
    await prefs.setString('themeMode', themeMode.value.name);
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('themeMode', mode.name)) {
      throw StateError('Could not save your preference.');
    }
    themeMode.value = mode;
  }

  Future<void> loadLikes(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    _likesKey = 'likes.$userId';
    _liked = (prefs.getStringList(_likesKey!) ?? []).toSet();
    notifyListeners();
  }

  bool isLiked(String key) => _liked.contains(key);

  Future<void> toggleLike(String key) async {
    if (_likesKey == null || savingLike) return;
    final storageKey = _likesKey!;
    final next = {..._liked};
    if (!next.remove(key)) next.add(key);
    savingLike = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setStringList(storageKey, next.toList())) {
        throw StateError('Could not save your like.');
      }
      if (_likesKey == storageKey) _liked = next;
    } finally {
      savingLike = false;
      notifyListeners();
    }
  }

  void clearLikes() {
    _likesKey = null;
    _liked = {};
    notifyListeners();
  }

  @override
  void dispose() {
    themeMode.dispose();
    super.dispose();
  }
}
