import 'package:flutter/material.dart';
import 'package:your_days/screens/home/home_screen.dart';
import 'package:your_days/screens/journal/journal_hub_screen.dart';
import 'package:your_days/screens/journal/passcode_entry_screen.dart';
import 'package:your_days/screens/journal/passcode_setup_screen.dart';
import 'package:your_days/screens/settings/settings_screen.dart';
import 'package:your_days/screens/weekly_word/weekly_word_screen.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/widgets/navigation/app_bottom_nav.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    JournalHubScreen(),
    WeeklyWordScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── App lifecycle — session lock ───────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // nothing — PasscodeService tracks the timestamp internally
    } else if (state == AppLifecycleState.resumed) {
      final didLock = PasscodeService.instance.checkAndLockIfExpired();
      if (didLock && _currentIndex == 1) {
        // Journal was active; push them back to home and require re-auth
        setState(() => _currentIndex = 0);
      }
    }
  }

  // ── Tab navigation ─────────────────────────────────────────────────────────

  void _onTabTap(int index) {
    if (index == 1) {
      // Journal tab — requires authentication
      _handleJournalTap();
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _handleJournalTap() {
    if (PasscodeService.instance.isUnlocked) {
      setState(() => _currentIndex = 1);
      return;
    }

    final hasPinSet = PreferencesService.instance.hasPinSet;

    if (!hasPinSet) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PasscodeSetupScreen(
            onSuccess: () {
              Navigator.of(context).pop();
              setState(() => _currentIndex = 1);
            },
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => PasscodeEntryScreen(
            onSuccess: () {
              Navigator.of(context).pop();
              setState(() => _currentIndex = 1);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
