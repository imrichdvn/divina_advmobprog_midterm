import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';

void main() => runApp(const SebApp());

class SebApp extends StatelessWidget {
  const SebApp({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(412, 715),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, child) => ValueListenableBuilder<ThemeMode>(
      valueListenable: PreferencesService.instance.themeMode,
      builder: (context, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Divina',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF5F9FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.dark,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        themeMode: mode,
        initialRoute: '/splash',
        routes: {
          '/home': (_) => const SplashScreen(),
          '/login': (_) => const LogInScreen(),
          '/register': (_) => const RegisterScreen(),
          '/splash': (_) => const SplashScreen(),
        },
      ),
    ),
  );
}
