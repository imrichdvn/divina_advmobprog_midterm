import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/preferences_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    setState(() => _error = null);
    try {
      await PreferencesService.instance.load();
      final user = await UserService.instance.restoreSession();
      if (user != null) await PreferencesService.instance.loadLikes(user.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              user == null ? const LogInScreen() : HomeScreen(user: user),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Unable to restore your session. Check your connection.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F7FF),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gossipers',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1877F2),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              if (_error == null)
                const CircularProgressIndicator(color: Color(0xFF1877F2))
              else ...[
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _restore,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
