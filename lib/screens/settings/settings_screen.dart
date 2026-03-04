import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:your_days/app.dart';
import 'package:your_days/screens/journal/passcode_entry_screen.dart';
import 'package:your_days/screens/journal/passcode_setup_screen.dart';
import 'package:your_days/screens/splash_screen.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/journal_repository.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/theme/color_tokens.dart';
import 'package:your_days/utils/zodiac_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesService.instance;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final neutral800 =
        isLight ? ColorTokens.neutral800Light : ColorTokens.neutral800Dark;

    final birthdate = prefs.userBirthdateAsDateTime;
    final birthdateLabel = birthdate != null
        ? DateFormat('MMMM d, yyyy').format(birthdate)
        : 'Not set';

    final belief = prefs.beliefTrack;
    final beliefLabel = _beliefLabel(belief);
    final zodiac = prefs.zodiacSign;
    final zodiacLabel = zodiac != null
        ? '${ZodiacUtils.emoji(zodiac)} ${ZodiacUtils.displayName(zodiac)}'
        : 'Not set';

    final hasPinSet = prefs.hasPinSet;
    final themeMode = prefs.themeMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          children: [
            // ── Header ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Text(
                'Settings',
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: neutral800,
                ),
              ),
            ),

            // ── Profile ───────────────────────────────────────────────────
            _SectionHeader(label: 'YOUR PROFILE', neutral500: neutral500),
            _SettingsTile(
              label: 'Name',
              value: prefs.userName,
              isLight: isLight,
              onTap: () => _editName(context),
            ),
            _SettingsTile(
              label: 'Birthday',
              value: birthdateLabel,
              isLight: isLight,
              onTap: () => _editBirthdate(context),
            ),
            _SettingsTile(
              label: 'Belief Track',
              value: beliefLabel,
              isLight: isLight,
              onTap: () => _pickBeliefTrack(context),
            ),
            if (belief == 'astrology')
              _SettingsTile(
                label: 'Zodiac Sign',
                value: zodiacLabel,
                isLight: isLight,
                onTap: () => _pickZodiac(context),
              ),

            const SizedBox(height: 24),

            // ── Appearance ────────────────────────────────────────────────
            _SectionHeader(label: 'APPEARANCE', neutral500: neutral500),
            _ThemeTile(
              isLight: isLight,
              currentMode: themeMode,
              primary: primary,
              neutral500: neutral500,
              onChanged: (mode) {
                PreferencesService.instance.themeMode = mode;
                MyApp.themeNotifier.value = mode;
                AnalyticsService.instance.logThemeChanged(
                    newTheme: mode.name);
                setState(() {});
              },
            ),

            const SizedBox(height: 24),

            // ── Journal ───────────────────────────────────────────────────
            _SectionHeader(label: 'JOURNAL', neutral500: neutral500),
            if (hasPinSet) ...[
              _SettingsTile(
                label: 'Change PIN',
                value: '',
                isLight: isLight,
                onTap: () => _changePinFlow(context),
                trailing: Icon(
                  Icons.chevron_right,
                  color: neutral500,
                  size: 20,
                ),
              ),
              _SettingsTile(
                label: 'Remove PIN',
                value: 'Deletes all journal entries',
                isLight: isLight,
                valueDanger: true,
                onTap: () => _removePin(context),
              ),
            ] else
              _SettingsTile(
                label: 'Set up Journal PIN',
                value: 'Your journal is not protected yet',
                isLight: isLight,
                onTap: () => _setupPin(context),
                trailing: Icon(
                  Icons.chevron_right,
                  color: neutral500,
                  size: 20,
                ),
              ),

            const SizedBox(height: 24),

            // ── Data ──────────────────────────────────────────────────────
            _SectionHeader(label: 'DATA', neutral500: neutral500),
            _SettingsTile(
              label: 'Clear All Data',
              value: 'Resets the app to factory state',
              isLight: isLight,
              valueDanger: true,
              onTap: () => _clearAllData(context),
            ),

            const SizedBox(height: 24),

            // ── About ─────────────────────────────────────────────────────
            _SectionHeader(label: 'ABOUT', neutral500: neutral500),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    'Your Years',
                    style: GoogleFonts.lora(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Built to help you see time clearly.',
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: neutral500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _editName(BuildContext context) async {
    final controller =
        TextEditingController(text: PreferencesService.instance.userName);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _NameSheet(controller: controller),
    );
    if (result != null && result.trim().isNotEmpty) {
      PreferencesService.instance.userName = result.trim();
      if (mounted) setState(() {});
    }
  }

  void _editBirthdate(BuildContext context) async {
    final current = PreferencesService.instance.userBirthdateAsDateTime;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      helpText: 'SELECT YOUR BIRTHDAY',
    );
    if (picked != null) {
      PreferencesService.instance.userBirthdate =
          DateFormat('yyyy-MM-dd').format(picked);
      if (mounted) setState(() {});
    }
  }

  void _pickBeliefTrack(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BeliefSheet(
          current: PreferencesService.instance.beliefTrack),
    );
    if (result != null) {
      final old = PreferencesService.instance.beliefTrack;
      PreferencesService.instance.beliefTrack = result;
      AnalyticsService.instance.logBeliefTrackChanged(
          fromTrack: old, toTrack: result);
      if (mounted) setState(() {});
    }
  }

  void _pickZodiac(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ZodiacSheet(
          current: PreferencesService.instance.zodiacSign),
    );
    if (result != null) {
      PreferencesService.instance.zodiacSign = result;
      if (mounted) setState(() {});
    }
  }

  void _setupPin(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PasscodeSetupScreen(
        onSuccess: () {
          Navigator.of(context).pop();
          setState(() {});
        },
      ),
    ));
  }

  void _changePinFlow(BuildContext context) {
    // Capture colors before any navigation
    final isLight = Theme.of(context).brightness == Brightness.light;
    final snackBg = isLight
        ? ColorTokens.neutral800Light
        : ColorTokens.neutral100Dark;
    final snackText = isLight
        ? ColorTokens.neutral50Light
        : ColorTokens.neutral900Dark;

    // Step 1: verify current PIN
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PasscodeEntryScreen(
        onSuccess: () {
          // Step 2: set new PIN (replace the verify screen)
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => PasscodeSetupScreen(
              onSuccess: () {
                Navigator.of(context).pop();
                AnalyticsService.instance.logPinChanged();
                if (mounted) setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: snackBg,
                  content: Text('PIN updated',
                      style: GoogleFonts.nunito(color: snackText)),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
          ));
        },
      ),
    ));
  }

  void _removePin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Remove PIN?',
            style: GoogleFonts.lora(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete all your journal entries and remove the PIN. This cannot be undone.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete & Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    PasscodeService.instance.clearPin();
    await JournalRepository.instance.clearAllEntries();
    PreferencesService.instance.pinHash = null;
    if (mounted) setState(() {});
  }

  void _clearAllData(BuildContext context) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Clear all data?',
            style: GoogleFonts.lora(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete your journal entries, PIN, and all settings. The app will restart to its initial state.',
          style: GoogleFonts.nunito(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    PasscodeService.instance.clearPin();
    await JournalRepository.instance.clearAllEntries();
    await PreferencesService.instance.clearAll();
    AnalyticsService.instance.logDataCleared();
    // Re-init prefs so the app doesn't crash on next read
    await PreferencesService.init();
    // Restart the navigation stack back to splash (which will re-run onboarding)
    MyApp.themeNotifier.value = ThemeMode.system;
    if (mounted) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (_) => false,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _beliefLabel(String track) {
    switch (track) {
      case 'christian':
        return '✝ Christian';
      case 'muslim':
        return '☪ Muslim';
      case 'astrology':
        return '✦ Astrology';
      default:
        return '◎ General';
    }
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color neutral500;

  const _SectionHeader({required this.label, required this.neutral500});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: neutral500,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isLight;
  final VoidCallback onTap;
  final bool valueDanger;
  final Widget? trailing;

  const _SettingsTile({
    required this.label,
    required this.value,
    required this.isLight,
    required this.onTap,
    this.valueDanger = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;
    final neutral500 =
        isLight ? ColorTokens.neutral500Light : ColorTokens.neutral500Dark;
    final valueColor = valueDanger
        ? Theme.of(context).colorScheme.error
        : neutral500;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLight
                          ? ColorTokens.neutral800Light
                          : ColorTokens.neutral800Dark,
                    ),
                  ),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: valueColor),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right, color: neutral500, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final bool isLight;
  final ThemeMode currentMode;
  final Color primary;
  final Color neutral500;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({
    required this.isLight,
    required this.currentMode,
    required this.primary,
    required this.neutral500,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg =
        isLight ? ColorTokens.neutral100Light : ColorTokens.neutral100Dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isLight
                  ? ColorTokens.neutral800Light
                  : ColorTokens.neutral800Dark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final option in _options)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(option.mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: currentMode == option.mode
                            ? primary.withAlpha(30)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: currentMode == option.mode
                              ? primary
                              : neutral500.withAlpha(80),
                          width: currentMode == option.mode ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(option.icon,
                              size: 18,
                              color: currentMode == option.mode
                                  ? primary
                                  : neutral500),
                          const SizedBox(height: 4),
                          Text(
                            option.label,
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: currentMode == option.mode
                                  ? primary
                                  : neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static const _options = [
    _ThemeOption(mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_outlined),
    _ThemeOption(mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_outlined),
    _ThemeOption(mode: ThemeMode.system, label: 'System', icon: Icons.brightness_auto_outlined),
  ];
}

class _ThemeOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;
  const _ThemeOption({required this.mode, required this.label, required this.icon});
}

// ── Bottom sheets ─────────────────────────────────────────────────────────

class _NameSheet extends StatelessWidget {
  final TextEditingController controller;
  const _NameSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Name',
              style:
                  GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            style: GoogleFonts.nunito(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'What should we call you?',
              hintStyle: GoogleFonts.nunito(
                  color: isLight
                      ? ColorTokens.neutral500Light
                      : ColorTokens.neutral500Dark),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: FilledButton.styleFrom(backgroundColor: primary),
              child:
                  Text('Save', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeliefSheet extends StatelessWidget {
  final String current;
  const _BeliefSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    const options = [
      _BeliefOption('christian', '✝', 'Christian', 'Bible verses & scripture'),
      _BeliefOption('muslim', '☪', 'Muslim', 'Quran & hadith'),
      _BeliefOption('astrology', '✦', 'Astrology', 'Cosmic wisdom & signs'),
      _BeliefOption('general', '◎', 'General', 'Universal wisdom & quotes'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Belief Track',
              style:
                  GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'This shapes your Weekly Word.',
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: isLight
                    ? ColorTokens.neutral500Light
                    : ColorTokens.neutral500Dark),
          ),
          const SizedBox(height: 16),
          for (final opt in options)
            GestureDetector(
              onTap: () => Navigator.pop(context, opt.value),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isLight
                      ? ColorTokens.neutral100Light
                      : ColorTokens.neutral100Dark,
                  borderRadius: BorderRadius.circular(12),
                  border: opt.value == current
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    Text(opt.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.label,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text(opt.subtitle,
                            style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: isLight
                                    ? ColorTokens.neutral500Light
                                    : ColorTokens.neutral500Dark)),
                      ],
                    ),
                    const Spacer(),
                    if (opt.value == current)
                      Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BeliefOption {
  final String value, emoji, label, subtitle;
  const _BeliefOption(this.value, this.emoji, this.label, this.subtitle);
}

class _ZodiacSheet extends StatelessWidget {
  final String? current;
  const _ZodiacSheet({this.current});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Zodiac Sign',
              style:
                  GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: ZodiacUtils.allSigns.map((sign) {
              final selected = sign == current;
              return GestureDetector(
                onTap: () => Navigator.pop(context, sign),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? primary.withAlpha(25)
                        : (isLight
                            ? ColorTokens.neutral100Light
                            : ColorTokens.neutral100Dark),
                    borderRadius: BorderRadius.circular(10),
                    border: selected
                        ? Border.all(color: primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ZodiacUtils.emoji(sign),
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        ZodiacUtils.displayName(sign),
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? primary
                              : (isLight
                                  ? ColorTokens.neutral600Light
                                  : ColorTokens.neutral600Dark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
