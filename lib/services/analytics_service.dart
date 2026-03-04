// Stub analytics service — ready to wire up firebase_analytics in a future phase.
// TODO(phase-analytics): add firebase_analytics package and activate event calls.

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  // ── App lifecycle ──────────────────────────────────────────────────────────
  Future<void> logAppOpen({required int dayOfYear, required String theme}) async {
    // TODO: FirebaseAnalytics.instance.logEvent(name: 'app_open', parameters: {...})
  }

  Future<void> logOnboardingStarted() async {}

  Future<void> logOnboardingCompleted({
    required String beliefTrack,
    required bool hasZodiac,
    required bool hasBirthdate,
  }) async {}

  Future<void> logOnboardingSkipped({required int skippedAtStep}) async {}

  // ── Dot grid ───────────────────────────────────────────────────────────────
  Future<void> logDotTapped({
    required String state, // 'exhausted' | 'today' | 'remaining'
    required int dayOfYear,
  }) async {}

  Future<void> logGridScreenshotShared() async {}

  // ── Journal (metadata only — never content) ────────────────────────────────
  Future<void> logJournalPasscodeSet() async {}

  Future<void> logJournalUnlocked({required String method}) async {}

  Future<void> logJournalUnlockFailed({required int attemptNumber}) async {}

  Future<void> logJournalEntryCreated({
    required int dayOfYear,
    required int wordCount,
    required int dayOfWeek,
  }) async {}

  Future<void> logJournalEntryEdited({
    required int dayOfYear,
    required int wordCount,
  }) async {}

  Future<void> logJournalEntryDeleted({required int dayOfYear}) async {}

  Future<void> logJournalStreak({required int streakLength}) async {}

  Future<void> logJournalSearchUsed() async {}

  // ── Weekly word ────────────────────────────────────────────────────────────
  Future<void> logWeeklyWordViewed({
    required String beliefTrack,
    required int weekNumber,
  }) async {}

  Future<void> logWeeklyWordShared({
    required String beliefTrack,
    required int weekNumber,
  }) async {}

  Future<void> logBeliefTrackChanged({
    required String fromTrack,
    required String toTrack,
  }) async {}

  // ── Settings ───────────────────────────────────────────────────────────────
  Future<void> logThemeChanged({required String newTheme}) async {}

  Future<void> logPinChanged() async {}

  Future<void> logBiometricToggled({required bool enabled}) async {}

  Future<void> logDataCleared() async {}
}
