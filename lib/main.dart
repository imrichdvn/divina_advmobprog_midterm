import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/preferences_service.dart';

void main() => runApp(const WillBook());

class WillBook extends StatelessWidget {
  const WillBook({super.key});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: const Size(412, 715),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, child) => ValueListenableBuilder<ThemeMode>(
      valueListenable: PreferencesService.instance.themeMode,
      builder: (context, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Willbook',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0167F8)),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0167F8),
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
