import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/theme/color_tokens.dart';

// ── Progress dots ─────────────────────────────────────────────────────────────

class OnboardingProgressDots extends StatelessWidget {
  final int current; // 1-based
  final int total;

  const OnboardingProgressDots({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final inactive =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isActive = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? primary : inactive,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ── Shared scaffold ───────────────────────────────────────────────────────────

class OnboardingShell extends StatelessWidget {
  final int step;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onSkip;

  const OnboardingShell({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.child,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: progress dots + optional skip
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OnboardingProgressDots(current: step, total: totalSteps),
                  if (onSkip != null)
                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: neutral500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Body
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ── Slide route ───────────────────────────────────────────────────────────────

Route<T> onboardingSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}
