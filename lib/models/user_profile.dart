class UserProfile {
  final String name;
  final DateTime? birthdate;
  final String beliefTrack; // 'christian' | 'muslim' | 'astrology' | 'general'
  final String? zodiacSign;

  const UserProfile({
    required this.name,
    this.birthdate,
    this.beliefTrack = 'general',
    this.zodiacSign,
  });

  UserProfile copyWith({
    String? name,
    DateTime? birthdate,
    String? beliefTrack,
    String? zodiacSign,
  }) {
    return UserProfile(
      name: name ?? this.name,
      birthdate: birthdate ?? this.birthdate,
      beliefTrack: beliefTrack ?? this.beliefTrack,
      zodiacSign: zodiacSign ?? this.zodiacSign,
    );
  }
}
