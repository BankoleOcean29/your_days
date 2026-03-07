import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/constants.dart';
import 'package:your_days/widgets/inputs/pin_input.dart';

class PasscodeSetupScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasscodeSetupScreen({super.key, required this.onSuccess});

  @override
  State<PasscodeSetupScreen> createState() => _PasscodeSetupScreenState();
}

class _PasscodeSetupScreenState extends State<PasscodeSetupScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _firstPin; // saved after step 1
  bool _confirming = false;
  bool _hasError = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_pin.length >= AppConstants.kPinLength) return;
    setState(() {
      _pin += d;
      _hasError = false;
    });
    if (_pin.length == AppConstants.kPinLength) {
      Future.delayed(const Duration(milliseconds: 120), _onPinComplete);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onPinComplete() {
    if (!_confirming) {
      // Step 1 — save first PIN and ask to confirm
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _confirming = true;
      });
    } else {
      // Step 2 — compare
      if (_pin == _firstPin) {
        _succeed();
      } else {
        _mismatch();
      }
    }
  }

  void _succeed() {
    PasscodeService.instance.savePin(_pin);
    PasscodeService.instance.unlock(_pin);
    AnalyticsService.instance.logJournalPasscodeSet();
    AnalyticsService.instance.logPinSetupCompleted();
    widget.onSuccess();
  }

  void _mismatch() {
    setState(() => _hasError = true);
    _shakeController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _pin = '';
          _hasError = false;
          // Return to step 1 so user tries again from scratch
          _firstPin = null;
          _confirming = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    final title = _confirming ? 'Confirm your PIN' : 'Create a PIN';
    final subtitle = _confirming
        ? 'Enter the same 4 digits again'
        : 'Your journal is protected by this PIN';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _confirming
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _pin = '';
                  _firstPin = null;
                  _confirming = false;
                  _hasError = false;
                }),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isLight
                    ? ColorTokens.neutral900Light
                    : ColorTokens.neutral900Dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.nunito(fontSize: 15, color: neutral600),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PinDots(
                    filled: _pin.length,
                    hasError: _hasError,
                    shakeAnimation: _shakeAnimation,
                  ),

                  if (_hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      "PINs don't match. Try again.",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  PinKeypad(
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
