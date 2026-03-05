import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/onboarding/name_screen.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/screens/onboarding/onboarding_widgets.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/widgets/buttons/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    Navigator.of(context).push(
      onboardingSlideRoute(NameScreen(data: OnboardingData())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    return PopScope(
      canPop: false, // Welcome is the root of the onboarding flow
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Centered content block ──────────────────────────────────
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Decorative mini dot grid ─────────────────────────
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (_, __) => CustomPaint(
                                painter: _MiniDotPainter(
                                  todayScale: _pulse.value,
                                  exhaustedColor: isLight
                                      ? ColorTokens.dotExhaustedLight
                                      : ColorTokens.dotExhaustedDark,
                                  todayColor: primary,
                                  remainingColor: isLight
                                      ? ColorTokens.dotRemainingLight
                                      : ColorTokens.dotRemainingDark,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Title ────────────────────────────────────────────
                        Text(
                          'See your year\nunfold.',
                          style: GoogleFonts.lora(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: isLight
                                ? ColorTokens.neutral900Light
                                : ColorTokens.neutral900Dark,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Subtitle ─────────────────────────────────────────
                        Text(
                          '365 dots. One for each day. Watch as the year fills in — and make the most of what\'s left.',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: neutral600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── CTA ──────────────────────────────────────────────────────
                PrimaryButton(label: 'Get started', onPressed: _next),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Decorative 8×5 mini dot painter (40 dots showing the concept) ─────────────

class _MiniDotPainter extends CustomPainter {
  static const int _cols = 8;
  static const int _rows = 5;
  static const int _total = 40;
  static const int _currentDay = 22; // concept: ~half past

  final double todayScale;
  final Color exhaustedColor;
  final Color todayColor;
  final Color remainingColor;

  const _MiniDotPainter({
    required this.todayScale,
    required this.exhaustedColor,
    required this.todayColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final spacingX = size.width / (_cols + 1);
    final spacingY = size.height / (_rows + 1);
    final baseRadius = spacingX * 0.35;
    final paint = Paint()..style = PaintingStyle.fill;

    int day = 0;
    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _cols; col++) {
        day++;
        if (day > _total) return;
        final x = spacingX * (col + 1);
        final y = spacingY * (row + 1);
        final isToday = day == _currentDay;
        final radius = isToday ? baseRadius * todayScale : baseRadius;

        paint.color = day < _currentDay
            ? exhaustedColor
            : isToday
                ? todayColor
                : remainingColor;

        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniDotPainter old) =>
      old.todayScale != todayScale;
}
