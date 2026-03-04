import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._(this._prefs);

  static PreferencesService? _instance;
  static PreferencesService get instance {
    assert(_instance != null,
        'PreferencesService.init() must be called before accessing instance.');
    return _instance!;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService._(prefs);
  }

  final SharedPreferences _prefs;

  // ── Keys ───────────────────────────────────────────────────────────────────
  static const _kOnboardingCompleted = 'onboarding_completed';
  static const _kOnboardingStep = 'onboarding_step';
  static const _kUserName = 'user_name';
  static const _kUserBirthdate = 'user_birthdate';
  static const _kBeliefTrack = 'belief_track';
  static const _kZodiacSign = 'zodiac_sign';
  static const _kThemeMode = 'theme_mode';
  static const _kPinHash = 'pin_hash';
  static const _kBiometricEnabled = 'biometric_enabled';
  static const _kSessionUnlockedAt = 'journal_session_unlocked_at';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  bool get onboardingCompleted =>
      _prefs.getBool(_kOnboardingCompleted) ?? false;
  set onboardingCompleted(bool v) => _prefs.setBool(_kOnboardingCompleted, v);

  int get onboardingStep => _prefs.getInt(_kOnboardingStep) ?? 0;
  set onboardingStep(int v) => _prefs.setInt(_kOnboardingStep, v);

  // ── User profile ───────────────────────────────────────────────────────────
  String get userName => _prefs.getString(_kUserName) ?? 'Friend';
  set userName(String v) => _prefs.setString(_kUserName, v);

  String? get userBirthdate => _prefs.getString(_kUserBirthdate);
  set userBirthdate(String? v) {
    if (v == null) {
      _prefs.remove(_kUserBirthdate);
    } else {
      _prefs.setString(_kUserBirthdate, v);
    }
  }

  DateTime? get userBirthdateAsDateTime {
    final s = userBirthdate;
    return s != null ? DateTime.tryParse(s) : null;
  }

  // ── Belief track ───────────────────────────────────────────────────────────
  String get beliefTrack => _prefs.getString(_kBeliefTrack) ?? 'general';
  set beliefTrack(String v) => _prefs.setString(_kBeliefTrack, v);

  String? get zodiacSign => _prefs.getString(_kZodiacSign);
  set zodiacSign(String? v) {
    if (v == null) {
      _prefs.remove(_kZodiacSign);
    } else {
      _prefs.setString(_kZodiacSign, v);
    }
  }

  // ── Theme ──────────────────────────────────────────────────────────────────
  /// Returns 'light', 'dark', or 'system'.
  String get themeModeString => _prefs.getString(_kThemeMode) ?? 'system';
  set themeModeString(String v) => _prefs.setString(_kThemeMode, v);

  ThemeMode get themeMode {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  set themeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
  }

  // ── Journal PIN ────────────────────────────────────────────────────────────
  String? get pinHash => _prefs.getString(_kPinHash);
  set pinHash(String? v) {
    if (v == null) {
      _prefs.remove(_kPinHash);
    } else {
      _prefs.setString(_kPinHash, v);
    }
  }

  bool get hasPinSet => pinHash != null;

  bool get biometricEnabled => _prefs.getBool(_kBiometricEnabled) ?? false;
  set biometricEnabled(bool v) => _prefs.setBool(_kBiometricEnabled, v);

  int? get sessionUnlockedAt => _prefs.getInt(_kSessionUnlockedAt);
  set sessionUnlockedAt(int? v) {
    if (v == null) {
      _prefs.remove(_kSessionUnlockedAt);
    } else {
      _prefs.setInt(_kSessionUnlockedAt, v);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<void> clearAll() => _prefs.clear();
}
