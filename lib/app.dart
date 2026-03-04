import 'package:flutter/material.dart';
import 'package:your_days/screens/splash_screen.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// A notifier so Settings can trigger a hot theme-mode swap without restart.
  static final themeNotifier = ValueNotifier<ThemeMode>(
    PreferencesService.instance.themeMode,
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (_, themeMode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Your Years',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}
