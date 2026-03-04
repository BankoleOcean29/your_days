import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/onboarding/birthdate_screen.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/screens/onboarding/onboarding_widgets.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/widgets/buttons/primary_button.dart';

class NameScreen extends StatefulWidget {
  final OnboardingData data;

  const NameScreen({super.key, required this.data});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.data.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    widget.data.name = _controller.text.trim();
    Navigator.of(context).push(
      onboardingSlideRoute(BirthdateScreen(data: widget.data)),
    );
  }

  void _skip() {
    widget.data.name = '';
    Navigator.of(context).push(
      onboardingSlideRoute(BirthdateScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    return OnboardingShell(
      step: 2,
      totalSteps: 5,
      onSkip: _skip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text(
              "What's your name?",
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
              "We'll use this to personalize your experience.",
              style: GoogleFonts.nunito(fontSize: 15, color: neutral600),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 50,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.nunito(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: GoogleFonts.nunito(color: neutral600),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_controller.text.trim().isNotEmpty) _next();
              },
            ),

            const Spacer(),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final canContinue = value.text.trim().isNotEmpty;
                return PrimaryButton(
                  label: 'Continue',
                  onPressed: canContinue ? _next : null,
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
