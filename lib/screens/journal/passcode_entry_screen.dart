import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/journal_repository.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/constants.dart';
import 'package:your_days/widgets/inputs/pin_input.dart';

class PasscodeEntryScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasscodeEntryScreen({super.key, required this.onSuccess});

  @override
  State<PasscodeEntryScreen> createState() => _PasscodeEntryScreenState();
}

class _PasscodeEntryScreenState extends State<PasscodeEntryScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _hasError = false;
  int _failedAttempts = 0;
  bool _coolingDown = false;
  int _cooldownRemaining = 0;

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
    if (_coolingDown || _pin.length >= AppConstants.kPinLength) return;
    setState(() {
      _pin += d;
      _hasError = false;
    });
    if (_pin.length == AppConstants.kPinLength) {
      Future.delayed(const Duration(milliseconds: 120), _verify);
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _verify() {
    if (PasscodeService.instance.verifyPin(_pin)) {
      PasscodeService.instance.unlock(_pin);
      AnalyticsService.instance.logJournalUnlocked(method: 'pin');
      widget.onSuccess();
    } else {
      _failedAttempts++;
      AnalyticsService.instance.logJournalUnlockFailed(
          attemptNumber: _failedAttempts);

      setState(() => _hasError = true);
      _shakeController.forward(from: 0).then((_) {
        if (!mounted) return;
        if (_failedAttempts >= AppConstants.kMaxPinAttempts) {
          setState(() {
            _pin = '';
            _hasError = false;
          });
          _startCooldown();
        } else {
          setState(() {
            _pin = '';
            _hasError = false;
          });
        }
      });
    }
  }

  void _startCooldown() {
    setState(() {
      _coolingDown = true;
      _cooldownRemaining = AppConstants.kPinCooldownSeconds;
      _failedAttempts = 0;
    });
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _cooldownRemaining--);
      if (_cooldownRemaining > 0) {
        _tick();
      } else {
        setState(() => _coolingDown = false);
      }
    });
  }

  Future<void> _forgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset PIN?',
          style: GoogleFonts.lora(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Resetting your PIN will permanently delete ALL your journal entries. This cannot be undone.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete & Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Clear all journal data and PIN
    PasscodeService.instance.clearPin();
    await JournalRepository.instance.clearAllEntries();
    PreferencesService.instance.pinHash = null;

    if (!mounted) return;
    // Pop back to let MainScaffold re-run auth (will show PasscodeSetupScreen)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral600 =
        isLight ? ColorTokens.neutral600Light : ColorTokens.neutral600Dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Journal',
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            Text(
              'Enter your PIN',
              style: GoogleFonts.lora(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isLight
                    ? ColorTokens.neutral900Light
                    : ColorTokens.neutral900Dark,
              ),
            ),

            const SizedBox(height: 8),

            if (_coolingDown)
              Text(
                'Too many attempts. Try again in $_cooldownRemaining s',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            else
              Text(
                _failedAttempts > 0
                    ? '${AppConstants.kMaxPinAttempts - _failedAttempts} attempts remaining'
                    : 'Your journal is private',
                style: GoogleFonts.nunito(fontSize: 14, color: neutral600),
              ),

            const Spacer(),

            PinDots(
              filled: _coolingDown ? 0 : _pin.length,
              hasError: _hasError,
              shakeAnimation: _shakeAnimation,
            ),

            const Spacer(),

            PinKeypad(
              onDigit: _onDigit,
              onDelete: _onDelete,
              enabled: !_coolingDown,
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: _forgotPin,
              child: Text(
                'Forgot PIN?',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: neutral500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
