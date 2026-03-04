import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/screens/onboarding/onboarding_widgets.dart';
import 'package:your_days/screens/onboarding/reveal_screen.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/zodiac_utils.dart';
import 'package:your_days/widgets/buttons/primary_button.dart';

class ZodiacScreen extends StatefulWidget {
  final OnboardingData data;

  const ZodiacScreen({super.key, required this.data});

  @override
  State<ZodiacScreen> createState() => _ZodiacScreenState();
}

class _ZodiacScreenState extends State<ZodiacScreen> {
  String? _selected;
  bool _autoDetected = false;

  @override
  void initState() {
    super.initState();
    // Pre-select from birthdate if available
    if (widget.data.birthdate != null) {
      final detected = ZodiacUtils.fromBirthdate(widget.data.birthdate!);
      if (detected != null) {
        _selected = detected;
        _autoDetected = true;
      }
    }
  }

  void _next() {
    if (_selected == null) return;
    widget.data.zodiacSign = _selected;
    Navigator.of(context).push(
      onboardingSlideRoute(RevealScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;
    final astroColor = isLight
        ? ColorTokens.astrologyLight
        : ColorTokens.astrologyDark;

    return OnboardingShell(
      step: 4,
      totalSteps: 5,
      // No skip — required if astrology was selected
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text(
              "What's your sign?",
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
              'Your weekly word will be tailored to your zodiac sign.',
              style: GoogleFonts.nunito(fontSize: 15, color: neutral600),
            ),

            if (_autoDetected && _selected != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: astroColor),
                  const SizedBox(width: 6),
                  Text(
                    'Based on your birthday: ${ZodiacUtils.displayName(_selected!)}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: astroColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // 3×4 zodiac grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: ZodiacUtils.allSigns.map((sign) {
                  final isChosen = _selected == sign;
                  final cardBg = isLight
                      ? ColorTokens.neutral100Light
                      : ColorTokens.neutral100Dark;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selected = sign;
                      _autoDetected = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isChosen
                            ? primary.withAlpha(20)
                            : cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isChosen ? primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ZodiacUtils.emoji(sign),
                            style: const TextStyle(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ZodiacUtils.displayName(sign),
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: isChosen
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isChosen
                                  ? primary
                                  : (isLight
                                      ? ColorTokens.neutral700Light
                                      : ColorTokens.neutral700Dark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

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
