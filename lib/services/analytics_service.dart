import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  // ── App lifecycle ──────────────────────────────────────────────────────────
  Future<void> logAppOpen({required int dayOfYear, required String theme}) =>
      _analytics.logEvent(name: 'app_open', parameters: {
        'day_of_year': dayOfYear,
        'theme': theme,
      });

  Future<void> logOnboardingStarted() =>
      _analytics.logEvent(name: 'onboarding_started');

  Future<void> logOnboardingCompleted({
    required String beliefTrack,
    required bool hasZodiac,
    required bool hasBirthdate,
  }) =>
      _analytics.logEvent(name: 'onboarding_completed', parameters: {
        'belief_track': beliefTrack,
        'has_zodiac': hasZodiac,
        'has_birthdate': hasBirthdate,
      });

  Future<void> logOnboardingSkipped({required int skippedAtStep}) =>
      _analytics.logEvent(name: 'onboarding_skipped', parameters: {
        'skipped_at_step': skippedAtStep,
      });

  // ── Dot grid ───────────────────────────────────────────────────────────────
  Future<void> logDotTapped({
    required String state,
    required int dayOfYear,
  }) =>
      _analytics.logEvent(name: 'dot_tapped', parameters: {
        'state': state,
        'day_of_year': dayOfYear,
      });

  Future<void> logGridScreenshotShared() =>
      _analytics.logEvent(name: 'grid_screenshot_shared');

  // ── Journal (metadata only — never content) ────────────────────────────────

  /// Fired when PIN setup flow completes successfully (first-time or change).
  Future<void> logPinSetupCompleted() =>
      _analytics.logEvent(name: 'pin_setup_completed');

  Future<void> logJournalPasscodeSet() =>
      _analytics.logEvent(name: 'journal_passcode_set');

  Future<void> logJournalUnlocked({required String method}) =>
      _analytics.logEvent(name: 'journal_unlocked', parameters: {
        'method': method,
      });

  Future<void> logJournalUnlockFailed({required int attemptNumber}) =>
      _analytics.logEvent(name: 'journal_unlock_failed', parameters: {
        'attempt_number': attemptNumber,
      });

  Future<void> logJournalEntryCreated({
    required int dayOfYear,
    required int wordCount,
    required int dayOfWeek,
  }) =>
      _analytics.logEvent(name: 'journal_entry_created', parameters: {
        'day_of_year': dayOfYear,
        'word_count': wordCount,
        'day_of_week': dayOfWeek,
      });

  Future<void> logJournalEntryEdited({
    required int dayOfYear,
    required int wordCount,
  }) =>
      _analytics.logEvent(name: 'journal_entry_edited', parameters: {
        'day_of_year': dayOfYear,
        'word_count': wordCount,
      });

  Future<void> logJournalEntryDeleted({required int dayOfYear}) =>
      _analytics.logEvent(name: 'journal_entry_deleted', parameters: {
        'day_of_year': dayOfYear,
      });

  Future<void> logJournalStreak({required int streakLength}) =>
      _analytics.logEvent(name: 'journal_streak', parameters: {
        'streak_length': streakLength,
      });

  /// Unified save event — replaces separate created/edited events in the UI.
  /// [dayOfWeek] is lowercase Monday–Sunday.
  /// [wordCountBucket] is 'short' (<50 words), 'medium' (50–200), 'long' (>200).
  Future<void> logJournalEntrySaved({
    required String dayOfWeek,
    required String wordCountBucket,
    required bool isEdit,
  }) =>
      _analytics.logEvent(name: 'journal_entry_saved', parameters: {
        'day_of_week': dayOfWeek,
        'word_count_bucket': wordCountBucket,
        'is_edit': isEdit,
      });

  /// Fired once per session view of the journal list (after successful unlock).
  Future<void> logJournalHistoryViewed() =>
      _analytics.logEvent(name: 'journal_history_viewed');

  Future<void> logJournalSearchUsed() =>
      _analytics.logEvent(name: 'journal_search_used');

  // ── Weekly word ────────────────────────────────────────────────────────────
  Future<void> logWeeklyWordViewed({
    required String beliefTrack,
    required int weekNumber,
  }) =>
      _analytics.logEvent(name: 'weekly_word_viewed', parameters: {
        'belief_track': beliefTrack,
        'week_number': weekNumber,
      });

  /// Fired when the Weekly Word tab becomes active.
  Future<void> logWordsSectionViewed({
    required String beliefTrack,
    required int weekNumber,
  }) =>
      _analytics.logEvent(name: 'words_section_viewed', parameters: {
        'belief_track': beliefTrack,
        'week_number': weekNumber,
      });

  Future<void> logWeeklyWordShared({
    required String beliefTrack,
    required int weekNumber,
  }) =>
      _analytics.logEvent(name: 'weekly_word_shared', parameters: {
        'belief_track': beliefTrack,
        'week_number': weekNumber,
      });

  /// Fired whenever a belief track is explicitly chosen (settings or onboarding).
  Future<void> logTrackSelected({required String track}) =>
      _analytics.logEvent(name: 'track_selected', parameters: {
        'track': track,
      });

  Future<void> logBeliefTrackChanged({
    required String fromTrack,
    required String toTrack,
  }) =>
      _analytics.logEvent(name: 'belief_track_changed', parameters: {
        'from_track': fromTrack,
        'to_track': toTrack,
      });

  // ── Settings ───────────────────────────────────────────────────────────────
  Future<void> logThemeChanged({required String newTheme}) =>
      _analytics.logEvent(name: 'theme_changed', parameters: {
        'new_theme': newTheme,
      });

  Future<void> logPinChanged() =>
      _analytics.logEvent(name: 'pin_changed');

  Future<void> logBiometricToggled({required bool enabled}) =>
      _analytics.logEvent(name: 'biometric_toggled', parameters: {
        'enabled': enabled,
      });

  Future<void> logDataCleared() =>
      _analytics.logEvent(name: 'data_cleared');
}
