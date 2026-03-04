import 'package:your_days/models/journal_entry.dart';
import 'package:your_days/services/analytics_service.dart';
import 'package:your_days/services/database_service.dart';
import 'package:your_days/services/encryption_service.dart';
import 'package:your_days/services/passcode_service.dart';
import 'package:your_days/utils/date_utils.dart';

class JournalRepository {
  JournalRepository._();
  static final JournalRepository instance = JournalRepository._();

  String get _pin => PasscodeService.instance.sessionPin!;

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<JournalEntry?> getEntry(String date) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'journal_entries',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _decrypt(rows.first);
  }

  Future<JournalEntry?> getTodayEntry() async {
    return getEntry(AppDateUtils.toStorageKey(DateTime.now()));
  }

  Future<List<JournalEntry>> getAllEntries() async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'journal_entries',
      orderBy: 'date DESC',
    );
    return rows.map(_decrypt).whereType<JournalEntry>().toList();
  }

  Future<List<JournalEntry>> searchEntries(String query) async {
    final all = await getAllEntries();
    final lower = query.toLowerCase();
    return all
        .where((e) => e.body.toLowerCase().contains(lower))
        .toList();
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> saveEntry(JournalEntry entry) async {
    final db = await DatabaseService.database;
    final encrypted =
        EncryptionService.instance.encrypt(entry.body, _pin);
    final isNew = entry.id == null;

    if (isNew) {
      await db.insert('journal_entries', entry.toMap(encrypted));
    } else {
      await db.update(
        'journal_entries',
        entry.toMap(encrypted),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
    }

    final action = isNew ? 'created' : 'edited';
    await DatabaseService.logAnalytics(
      date: entry.date,
      action: action,
      wordCount: entry.wordCount,
    );

    final dayOfYear = AppDateUtils.dayOfYear(DateTime.parse(entry.date));
    if (isNew) {
      await AnalyticsService.instance.logJournalEntryCreated(
        dayOfYear: dayOfYear,
        wordCount: entry.wordCount,
        dayOfWeek: DateTime.parse(entry.date).weekday,
      );
    } else {
      await AnalyticsService.instance.logJournalEntryEdited(
        dayOfYear: dayOfYear,
        wordCount: entry.wordCount,
      );
    }

    await _checkAndLogStreak();
  }

  Future<void> deleteEntry(JournalEntry entry) async {
    final db = await DatabaseService.database;
    await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [entry.id],
    );

    final dayOfYear = AppDateUtils.dayOfYear(DateTime.parse(entry.date));
    await DatabaseService.logAnalytics(
      date: entry.date,
      action: 'deleted',
      wordCount: 0,
    );
    await AnalyticsService.instance.logJournalEntryDeleted(
        dayOfYear: dayOfYear);
  }

  Future<void> clearAllEntries() async {
    final db = await DatabaseService.database;
    await db.delete('journal_entries');
    await db.delete('journal_analytics');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  JournalEntry? _decrypt(Map<String, dynamic> row) {
    final encryptedBody = row['body'] as String;
    final body = EncryptionService.instance.decrypt(encryptedBody, _pin);
    if (body == null) return null; // decryption failed
    return JournalEntry.fromMap(row, body: body);
  }

  Future<void> _checkAndLogStreak() async {
    final dates = await DatabaseService.journalDates();
    if (dates.isEmpty) return;

    int streak = 1;
    for (int i = 0; i < dates.length - 1; i++) {
      final a = DateTime.parse(dates[i]);
      final b = DateTime.parse(dates[i + 1]);
      if (a.difference(b).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    // Only log if streak >= 2 (single entries are uninteresting)
    if (streak >= 2) {
      await AnalyticsService.instance.logJournalStreak(
          streakLength: streak);
    }
  }
}
