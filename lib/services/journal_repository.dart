import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
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

  // ── Web storage (SharedPreferences / localStorage) ─────────────────────────

  static const _kWebKey = 'web_journal_entries_v1';

  Future<List<Map<String, dynamic>>> _webLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kWebKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _webPersist(List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWebKey, jsonEncode(rows));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<JournalEntry?> getEntry(String date) async {
    if (kIsWeb) {
      final rows = await _webLoad();
      final match = rows.where((r) => r['date'] == date).firstOrNull;
      if (match == null) return null;
      return _decrypt(match);
    }
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
    if (kIsWeb) {
      final rows = await _webLoad();
      rows.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return rows.map(_decrypt).whereType<JournalEntry>().toList();
    }
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
    return all.where((e) => e.body.toLowerCase().contains(lower)).toList();
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> saveEntry(JournalEntry entry) async {
    final encrypted = EncryptionService.instance.encrypt(entry.body, _pin);
    final isNew = entry.id == null;

    if (kIsWeb) {
      final rows = await _webLoad();
      final encryptedMap = entry.toMap(encrypted);
      if (isNew) {
        // Generate a simple id for web storage
        final newId = DateTime.now().millisecondsSinceEpoch;
        encryptedMap['id'] = newId;
        rows.add(encryptedMap);
      } else {
        final idx = rows.indexWhere((r) => r['id'] == entry.id);
        if (idx >= 0) {
          rows[idx] = encryptedMap;
        } else {
          rows.add(encryptedMap);
        }
      }
      await _webPersist(rows);
    } else {
      final db = await DatabaseService.database;
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
      await DatabaseService.logAnalytics(
        date: entry.date,
        action: isNew ? 'created' : 'edited',
        wordCount: entry.wordCount,
      );
    }

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
    if (kIsWeb) {
      final rows = await _webLoad();
      rows.removeWhere((r) => r['id'] == entry.id);
      await _webPersist(rows);
    } else {
      final db = await DatabaseService.database;
      await db.delete(
        'journal_entries',
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      await DatabaseService.logAnalytics(
        date: entry.date,
        action: 'deleted',
        wordCount: 0,
      );
    }

    final dayOfYear = AppDateUtils.dayOfYear(DateTime.parse(entry.date));
    await AnalyticsService.instance.logJournalEntryDeleted(
        dayOfYear: dayOfYear);
  }

  Future<void> clearAllEntries() async {
    if (kIsWeb) {
      await _webPersist([]);
      return;
    }
    final db = await DatabaseService.database;
    await db.delete('journal_entries');
    await db.delete('journal_analytics');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  JournalEntry? _decrypt(Map<String, dynamic> row) {
    final encryptedBody = row['body'] as String;
    final body = EncryptionService.instance.decrypt(encryptedBody, _pin);
    if (body == null) return null;
    return JournalEntry.fromMap(row, body: body);
  }

  Future<void> _checkAndLogStreak() async {
    List<String> dates;
    if (kIsWeb) {
      final rows = await _webLoad();
      dates = rows
          .map((r) => r['date'] as String)
          .toList()
        ..sort((a, b) => b.compareTo(a));
    } else {
      dates = await DatabaseService.journalDates();
    }
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

    if (streak >= 2) {
      await AnalyticsService.instance.logJournalStreak(streakLength: streak);
    }
  }
}
