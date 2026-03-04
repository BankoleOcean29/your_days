import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/main_scaffold.dart';
import 'package:your_days/screens/onboarding/welcome_screen.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/preferences_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dotController;
  late final AnimationController _textController;
  late final Animation<double> _dotFade;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _dotFade = CurvedAnimation(parent: _dotController, curve: Curves.easeIn);
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    // Sequence: dot at 200ms, text at 500ms, navigate at 1500ms.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _dotController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final prefs = PreferencesService.instance;
    final isOnboarded = prefs.onboardingCompleted;

    AnalyticsService.instance.logAppOpen(
      dayOfYear: DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1,
      theme: Theme.of(context).brightness == Brightness.light ? 'light' : 'dark',
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            isOnboarded ? const MainScaffold() : const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _dotController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot
            FadeTransition(
              opacity: _dotFade,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // "Your Years"
            FadeTransition(
              opacity: _textFade,
              child: Text(
                'Your Years',
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
