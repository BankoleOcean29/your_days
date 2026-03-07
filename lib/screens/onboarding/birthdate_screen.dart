import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/screens/onboarding/belief_screen.dart';
import 'package:your_days/screens/onboarding/onboarding_data.dart';
import 'package:your_days/screens/onboarding/onboarding_widgets.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/widgets/buttons/primary_button.dart';
import 'package:intl/intl.dart';

class BirthdateScreen extends StatefulWidget {
  final OnboardingData data;

  const BirthdateScreen({super.key, required this.data});

  @override
  State<BirthdateScreen> createState() => _BirthdateScreenState();
}

class _BirthdateScreenState extends State<BirthdateScreen> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.data.birthdate;
  }

  bool _isValid(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    if (date.isAfter(now)) return false;
    if (date.isBefore(DateTime(1900))) return false;
    // Must be at least 5 years old
    final fiveYearsAgo = DateTime(now.year - 5, now.month, now.day);
    return !date.isAfter(fiveYearsAgo);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _selected ?? DateTime(now.year - 20);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      helpText: 'Select your birthdate',
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selected = picked);
    }
  }

  void _next() {
    widget.data.birthdate = _selected;
    Navigator.of(context).push(
      onboardingSlideRoute(BeliefScreen(data: widget.data)),
    );
  }

  void _skip() {
    widget.data.birthdate = null;
    Navigator.of(context).push(
      onboardingSlideRoute(BeliefScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral300 =
        isLight ? ColorTokens.neutral300Light : ColorTokens.neutral300Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;

    final hasDate = _isValid(_selected);
    final dateLabel = _selected != null
        ? DateFormat('MMMM d, yyyy').format(_selected!)
        : 'Tap to select';

    return OnboardingShell(
      step: 3,
      totalSteps: 5,
      onSkip: _skip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            Text(
              'When were you born?',
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
              'This helps us know how your year aligns with your age.',
              style: GoogleFonts.nunito(fontSize: 15, color: neutral600),
            ),

            const SizedBox(height: 32),

            // Date picker tap target
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasDate ? primary : neutral300,
                    width: hasDate ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: hasDate ? primary : neutral500,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dateLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: hasDate ? (isLight ? ColorTokens.neutral900Light : ColorTokens.neutral900Dark) : neutral500,
                        fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_selected != null && !_isValid(_selected)) ...[
              const SizedBox(height: 8),
              Text(
                'Please enter a valid birthdate.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],

            const Spacer(),

            PrimaryButton(
              label: 'Continue',
              onPressed: hasDate ? _next : null,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
