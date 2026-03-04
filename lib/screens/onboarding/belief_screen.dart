import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/screens/onboarding/onboarding_widgets.dart';
import 'package:your_days/screens/onboarding/reveal_screen.dart';
import 'package:your_days/screens/onboarding/zodiac_screen.dart';
import 'package:your_days/theme/belief_theme.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/widgets/buttons/primary_button.dart';

class BeliefScreen extends StatefulWidget {
  final OnboardingData data;

  const BeliefScreen({super.key, required this.data});

  @override
  State<BeliefScreen> createState() => _BeliefScreenState();
}

class _BeliefScreenState extends State<BeliefScreen> {
  String? _selected;

  static const _options = [
    _BeliefOption(
      track: 'christian',
      label: 'Christian',
      subtitle: 'Bible verses & devotional wisdom',
      emoji: '✝️',
    ),
    _BeliefOption(
      track: 'muslim',
      label: 'Muslim',
      subtitle: 'Quran verses & Islamic wisdom',
      emoji: '☪️',
    ),
    _BeliefOption(
      track: 'astrology',
      label: 'Astrology',
      subtitle: 'Weekly guidance by zodiac sign',
      emoji: '✨',
    ),
    _BeliefOption(
      track: 'general',
      label: 'None / General',
      subtitle: 'Secular quotes & wisdom',
      emoji: '💬',
    ),
  ];

  void _next() {
    if (_selected == null) return;
    widget.data.beliefTrack = _selected!;

    final next = widget.data.needsZodiac
        ? ZodiacScreen(data: widget.data)
        : RevealScreen(data: widget.data);

    Navigator.of(context).push(onboardingSlideRoute(next));
  }

  void _skip() {
    widget.data.beliefTrack = 'general';
    Navigator.of(context).push(
      onboardingSlideRoute(RevealScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;
    final beliefTheme =
        Theme.of(context).extension<BeliefTheme>() ?? BeliefTheme.light;

    return OnboardingShell(
      step: 4,
      totalSteps: 5,
      onSkip: _skip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text(
              'Choose your weekly word',
              style: GoogleFonts.lora(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isLight
                    ? ColorTokens.neutral900Light
                    : ColorTokens.neutral900Dark,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "We'll share a word or quote each week to reflect on. Pick what resonates with you.",
              style: GoogleFonts.nunito(fontSize: 15, color: neutral600),
            ),

            const SizedBox(height: 28),

            // Belief option cards
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final opt = _options[i];
                  final accentColor = beliefTheme.forTrack(opt.track);
                  final isChosen = _selected == opt.track;
                  return _BeliefCard(
                    option: opt,
                    accentColor: accentColor,
                    isSelected: isChosen,
                    isLight: isLight,
                    onTap: () => setState(() => _selected = opt.track),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Continue',
              onPressed: _selected != null ? _next : null,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Option card ───────────────────────────────────────────────────────────────

class _BeliefOption {
  final String track;
  final String label;
  final String subtitle;
  final String emoji;

  const _BeliefOption({
    required this.track,
    required this.label,
    required this.subtitle,
    required this.emoji,
  });
}

class _BeliefCard extends StatelessWidget {
  final _BeliefOption option;
  final Color accentColor;
  final bool isSelected;
  final bool isLight;
  final VoidCallback onTap;

  const _BeliefCard({
    required this.option,
    required this.accentColor,
    required this.isSelected,
    required this.isLight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;
    final neutral700 =
        isLight ? ColorTokens.neutral700Light : ColorTokens.neutral700Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withAlpha(20) : cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Emoji
            Text(option.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accentColor : neutral700,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: neutral500,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? accentColor : (isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
