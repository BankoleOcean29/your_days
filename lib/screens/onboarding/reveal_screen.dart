import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/main_scaffold.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/theme/dot_theme.dart';
import 'package:your_days/utils/constants.dart';
import 'package:your_days/utils/date_utils.dart';

class RevealScreen extends StatefulWidget {
  final OnboardingData data;

  const RevealScreen({super.key, required this.data});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with TickerProviderStateMixin {
  // Reveal animation — runs once when screen opens
  late final AnimationController _revealController;
  // Pulse — infinite loop after reveal
  late final AnimationController _pulseController;

  late final Animation<double> _exhaustedProgress; // 0→1: exhausted dots draw in
  late final Animation<double> _todayEntrance;      // 0→1: today's dot bounces in
  late final Animation<double> _remainingFade;      // 0→1: remaining dots fade in
  late final Animation<double> _statsFade;          // 0→1: stats bar fades in
  late final Animation<double> _ctaFade;            // 0→1: CTA button fades in
  late final Animation<double> _pulseAnimation;     // 1.0→1.15: today dot pulse

  bool _revealDone = false;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Exhausted dots draw in sequentially: 300ms → 1200ms
    _exhaustedProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.14, 0.55, curve: Curves.easeInOut),
      ),
    );

    // Today's dot bounces in: 800ms → 1100ms (elasticOut overshoots for bounce)
    _todayEntrance = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.36, 0.52, curve: Curves.elasticOut),
      ),
    );

    // Remaining dots fade in: 1000ms → 1300ms
    _remainingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.45, 0.60),
      ),
    );

    // Stats bar fades in: 1200ms → 1540ms
    _statsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.55, 0.70),
      ),
    );

    // CTA button fades in: 1500ms → 1900ms
    _ctaFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.68, 0.86),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start the reveal, then kick off pulse
    _revealController.forward().then((_) {
      if (mounted) {
        setState(() => _revealDone = true);
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    // Await every write so all data is flushed to disk before we navigate.
    await PreferencesService.instance.saveOnboardingData(
      displayName: widget.data.displayName,
      birthdate: widget.data.birthdate?.toIso8601String(),
      beliefTrack: widget.data.beliefTrack,
      zodiacSign: widget.data.zodiacSign,
    );

    AnalyticsService.instance.logOnboardingCompleted(
      beliefTrack: widget.data.beliefTrack,
      hasZodiac: widget.data.zodiacSign != null,
      hasBirthdate: widget.data.birthdate != null,
    );

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScaffold(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final currentDay = AppDateUtils.dayOfYear(now);
    final totalDays = AppDateUtils.totalDaysInYear(year);
    final daysRemaining = totalDays - currentDay;
    final percentageLeft = (daysRemaining / totalDays * 100).round();

    final dotTheme = Theme.of(context).extension<DotTheme>() ?? DotTheme.light;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;
    final trackBg =
        isLight ? ColorTokens.neutral200Light : ColorTokens.neutral200Dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_revealController, _pulseController]),
            builder: (context, _) {
              final todayScale = _revealDone
                  ? _pulseAnimation.value
                  : _todayEntrance.value;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // ── Title ─────────────────────────────────────────────
                    Text(
                      '${widget.data.displayName}, this is your $year',
                      style: GoogleFonts.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isLight
                            ? ColorTokens.neutral900Light
                            : ColorTokens.neutral900Dark,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Dot grid ──────────────────────────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final spacingX = w / (AppConstants.kGridColumns + 1);
                        final gridHeight =
                            spacingX * (AppConstants.kGridRows + 1);

                        return SizedBox(
                          height: gridHeight,
                          child: CustomPaint(
                            painter: _RevealDotPainter(
                              currentDayOfYear: currentDay,
                              totalDays: totalDays,
                              exhaustedProgress:
                                  _exhaustedProgress.value,
                              todayScale: todayScale,
                              remainingOpacity: _remainingFade.value,
                              exhaustedColor: dotTheme.exhausted,
                              todayColor: dotTheme.today,
                              remainingColor: dotTheme.remaining,
                            ),
                            size: Size(w, gridHeight),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Stats (fade in) ───────────────────────────────────
                    Opacity(
                      opacity: _statsFade.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: currentDay / totalDays,
                              minHeight: 6,
                              backgroundColor: trackBg,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                year.toString(),
                                style: GoogleFonts.lora(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: neutral600,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$percentageLeft% left',
                                    style: GoogleFonts.lora(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                  Text(
                                    'Day $currentDay · $daysRemaining days remaining',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── CTA (fade in) ─────────────────────────────────────
                    Opacity(
                      opacity: _ctaFade.value,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _ctaFade.value > 0.9 ? _complete : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Let's make it count",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Reveal dot painter ────────────────────────────────────────────────────────

class _RevealDotPainter extends CustomPainter {
  final int currentDayOfYear;
  final int totalDays;
  final double exhaustedProgress; // 0→1: fraction of exhausted dots drawn
  final double todayScale;         // 0→1+ for entrance/pulse
  final double remainingOpacity;   // 0→1
  final Color exhaustedColor;
  final Color todayColor;
  final Color remainingColor;

  static const int _columns = AppConstants.kGridColumns;
  static const int _rows = AppConstants.kGridRows;

  const _RevealDotPainter({
    required this.currentDayOfYear,
    required this.totalDays,
    required this.exhaustedProgress,
    required this.todayScale,
    required this.remainingOpacity,
    required this.exhaustedColor,
    required this.todayColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final spacingX = size.width / (_columns + 1);
    final spacingY = size.height / (_rows + 1);
    final baseRadius = spacingX * 0.35;
    final paint = Paint()..style = PaintingStyle.fill;

    // How many exhausted dots have appeared so far
    final exhaustedCount =
        ((currentDayOfYear - 1) * exhaustedProgress).round();

    int dayNumber = 0;
    for (int row = 0; row < _rows; row++) {
      for (int col = 0; col < _columns; col++) {
        dayNumber++;
        if (dayNumber > totalDays) return;

        final x = spacingX * (col + 1);
        final y = spacingY * (row + 1);

        if (dayNumber < currentDayOfYear) {
          if (dayNumber <= exhaustedCount) {
            paint.color = exhaustedColor;
            canvas.drawCircle(Offset(x, y), baseRadius, paint);
          }
        } else if (dayNumber == currentDayOfYear) {
          if (todayScale > 0) {
            paint.color = todayColor;
            canvas.drawCircle(Offset(x, y), baseRadius * todayScale, paint);
          }
        } else {
          if (remainingOpacity > 0) {
            paint.color =
                remainingColor.withAlpha((remainingOpacity * 255).round());
            canvas.drawCircle(Offset(x, y), baseRadius, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RevealDotPainter old) {
    return old.exhaustedProgress != exhaustedProgress ||
        old.todayScale != todayScale ||
        old.remainingOpacity != remainingOpacity;
  }
}
