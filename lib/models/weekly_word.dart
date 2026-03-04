class WeeklyWord {
  final String text;
  final String? reference; // "John 3:16", "Quran 2:286", "Marcus Aurelius", etc.
  final String reflection; // prompting question for the user

  const WeeklyWord({
    required this.text,
    this.reference,
    required this.reflection,
  });

  factory WeeklyWord.fromMap(Map<String, dynamic> m) {
    return WeeklyWord(
      text: m['text'] as String,
      reference: m['reference'] as String?,
      reflection: m['reflection'] as String,
    );
  }
}
