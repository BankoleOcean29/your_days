import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/app.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/theme/dot_theme.dart';
import 'package:your_days/utils/constants.dart';
import 'package:your_days/utils/date_utils.dart';
import 'package:your_days/widgets/cards/stat_card.dart';
import 'package:your_days/widgets/dot_grid/dot_bottom_sheet.dart';
import 'package:your_days/widgets/dot_grid/dot_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleDotTap(
    BuildContext context,
    int dayNumber,
    int currentDay,
    int totalDays,
  ) {
    if (dayNumber == currentDay) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    AnalyticsService.instance.logDotTapped(
      state: dayNumber < currentDay
          ? 'exhausted'
          : dayNumber == currentDay
              ? 'today'
              : 'remaining',
      dayOfYear: dayNumber,
    );

    DotBottomSheet.show(
      context,
      dayNumber: dayNumber,
      currentDayOfYear: currentDay,
      totalDays: totalDays,
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Home app bar — spec: "Your Years" Lora 22dp Bold primary + theme toggle ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your Years',
                      style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const Spacer(),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: MyApp.themeNotifier,
                      builder: (_, mode, __) {
                        final isDark =
                            mode == ThemeMode.dark ||
                            (mode == ThemeMode.system &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark);
                        return IconButton(
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: neutral500,
                            size: 22,
                          ),
                          onPressed: () {
                            final next = isDark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                            MyApp.themeNotifier.value = next;
                            PreferencesService.instance.themeMode = next;
                            AnalyticsService.instance.logThemeChanged(
                                newTheme: next.name);
                          },
                          tooltip: isDark ? 'Switch to light' : 'Switch to dark',
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Dot grid ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double w = constraints.maxWidth;
                    final double spacingX =
                        w / (AppConstants.kGridColumns + 1);
                    final double gridHeight =
                        spacingX * (AppConstants.kGridRows + 1);

                    return GestureDetector(
                      onTapUp: (details) {
                        final pos = details.localPosition;
                        final col =
                            ((pos.dx / spacingX) - 1).round();
                        final row =
                            ((pos.dy / spacingX) - 1).round(); // square spacing
                        if (col < 0 ||
                            col >= AppConstants.kGridColumns ||
                            row < 0 ||
                            row >= AppConstants.kGridRows) {
                          return;
                        }
                        final dayNumber =
                            row * AppConstants.kGridColumns + col + 1;
                        if (dayNumber < 1 || dayNumber > totalDays) return;
                        _handleDotTap(context, dayNumber, currentDay, totalDays);
                      },
                      child: SizedBox(
                        height: gridHeight,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, _) => CustomPaint(
                            painter: DotPainter(
                              currentDayOfYear: currentDay,
                              totalDays: totalDays,
                              todayScale: _pulseAnimation.value,
                              exhaustedColor: dotTheme.exhausted,
                              todayColor: dotTheme.today,
                              remainingColor: dotTheme.remaining,
                            ),
                            size: Size(w, gridHeight),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Progress bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: currentDay / totalDays,
                    minHeight: 6,
                    backgroundColor: trackBg,
                    // spec: fill at 0.7 opacity
                    valueColor: AlwaysStoppedAnimation<Color>(
                        primary.withAlpha(178)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Year
                    Text(
                      year.toString(),
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: neutral600,
                      ),
                    ),
                    // Percentage + day counter
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentageLeft% left',
                          style: GoogleFonts.lora(
                            fontSize: 32,
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
              ),

              const SizedBox(height: 24),

              // ── 2×2 Stat cards ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Current Week',
                            value: 'Week ${AppDateUtils.weekOfYear(now)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Quarter',
                            value: 'Q${AppDateUtils.currentQuarter(now)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Weeks Left',
                            value:
                                '${AppDateUtils.weeksRemainingInYear(now)}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Months Left',
                            value:
                                '${AppDateUtils.monthsRemainingInYear(now)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
