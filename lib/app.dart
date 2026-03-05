import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:your_days/screens/splash_screen.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/app_theme.dart';

// Maximum logical-pixel width for the app's content column.
// On screens wider than this (tablets, desktop browsers) the UI is centred
// inside a constrained box so it always looks like a mobile app.
const double _kMaxContentWidth = 520.0;

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
        title: 'Your Days',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        // Allow mouse/trackpad drag-to-scroll on web/desktop.
        scrollBehavior: _AppScrollBehavior(),
        // Global layout shell: centres content on wide screens.
        builder: _buildShell,
        home: const SplashScreen(),
      ),
    );
  }

  static Widget _buildShell(BuildContext context, Widget? child) {
    final mq = MediaQuery.of(context);

    // Narrow screens (phones): pass through untouched.
    if (mq.size.width <= _kMaxContentWidth) {
      return SelectionArea(child: child!);
    }

    // Wide screens (tablet / web): centre in a phone-width column.
    // Override MediaQuery.size so inner widgets (e.g. LayoutBuilder) still
    // think they are on a phone-sized canvas.
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: _kMaxContentWidth,
          child: MediaQuery(
            data: mq.copyWith(size: Size(_kMaxContentWidth, mq.size.height)),
            child: SelectionArea(child: child!),
          ),
        ),
      ),
    );
  }
}

/// Enables drag-to-scroll with mouse, stylus, and trackpad in addition to
/// touch, which is the default Flutter behaviour.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
