/// Accumulates onboarding choices as the user moves through the flow.
class OnboardingData {
  String name;
  DateTime? birthdate;
  String beliefTrack; // 'christian' | 'muslim' | 'astrology' | 'general'
  String? zodiacSign;

  OnboardingData({
    this.name = '',
    this.birthdate,
    this.beliefTrack = 'general',
    this.zodiacSign,
  });

  bool get needsZodiac => beliefTrack == 'astrology';
  String get displayName => name.trim().isEmpty ? 'Friend' : name.trim();
}
