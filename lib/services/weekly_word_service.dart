import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:your_days/models/weekly_word.dart';

class WeeklyWordService {
  WeeklyWordService._();

  static final WeeklyWordService instance = WeeklyWordService._();

  Map<String, dynamic>? _data;

  Future<void> init() async {
    final raw = await rootBundle.loadString('assets/data/weekly_words.json');
    _data = jsonDecode(raw) as Map<String, dynamic>;
  }

  bool get isReady => _data != null;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the word for the given ISO [weekNumber] (1–52), belief track,
  /// and optional zodiac sign (required when track == 'astrology').
  WeeklyWord? getForWeek(
    int weekNumber,
    String beliefTrack, {
    String? zodiacSign,
  }) {
    if (_data == null) return null;

    if (beliefTrack == 'astrology') {
      final sign = (zodiacSign ?? 'general').toLowerCase();
      final raw = (_data!['astrology'] as Map<String, dynamic>)[sign] as List?;
      if (raw == null || raw.isEmpty) return _fallback(weekNumber, 'general');
      final entries = raw
          .map((m) => WeeklyWord.fromMap(m as Map<String, dynamic>))
          .toList();
      return entries[(weekNumber - 1) % entries.length];
    }

    final raw = _data![beliefTrack] as List?;
    if (raw == null || raw.isEmpty) return _fallback(weekNumber, 'general');
    final entries =
        raw.map((m) => WeeklyWord.fromMap(m as Map<String, dynamic>)).toList();
    return entries[(weekNumber - 1) % entries.length];
  }

  /// Returns past weeks in reverse order (most recent first).
  List<({int week, WeeklyWord word})> getPastWords(
    int currentWeek,
    String beliefTrack, {
    String? zodiacSign,
  }) {
    final result = <({int week, WeeklyWord word})>[];
    for (int w = currentWeek - 1; w >= 1 && result.length < 12; w--) {
      final word =
          getForWeek(w, beliefTrack, zodiacSign: zodiacSign);
      if (word != null) result.add((week: w, word: word));
    }
    return result;
  }

  // ── Private ────────────────────────────────────────────────────────────────

  WeeklyWord? _fallback(int weekNumber, String track) {
    final raw = _data![track] as List?;
    if (raw == null || raw.isEmpty) return null;
    final entries =
        raw.map((m) => WeeklyWord.fromMap(m as Map<String, dynamic>)).toList();
    return entries[(weekNumber - 1) % entries.length];
  }
}
