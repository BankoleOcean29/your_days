import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    // On web, getDatabasesPath() is not meaningful with sqflite_common_ffi_web;
    // use a simple filename so the ffi-web factory maps it to IndexedDB correctly.
    final String fullPath;
    if (kIsWeb) {
      fullPath = 'your_years.db';
    } else {
      final dbPath = await getDatabasesPath();
      fullPath = '$dbPath/your_years.db';
    }

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE journal_entries (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            date       TEXT    UNIQUE NOT NULL,
            body       TEXT    NOT NULL,
            created_at TEXT    NOT NULL,
            updated_at TEXT    NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE journal_analytics (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            date       TEXT    NOT NULL,
            action     TEXT    NOT NULL,
            word_count INTEGER NOT NULL,
            timestamp  TEXT    NOT NULL,
            synced     INTEGER NOT NULL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE milestones (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            date       TEXT NOT NULL,
            title      TEXT NOT NULL,
            note       TEXT,
            category   TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert or update a journal analytics row (for Firebase sync later).
  static Future<void> logAnalytics({
    required String date,
    required String action, // 'created' | 'edited' | 'deleted'
    required int wordCount,
  }) async {
    final db = await database;
    await db.insert('journal_analytics', {
      'date': date,
      'action': action,
      'word_count': wordCount,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  /// Returns consecutive journal dates (for streak calc). Sorted DESC.
  static Future<List<String>> journalDates() async {
    final db = await database;
    final rows = await db.query(
      'journal_analytics',
      columns: ['date'],
      where: "action = 'created'",
      orderBy: 'date DESC',
      distinct: true,
    );
    return rows.map((r) => r['date'] as String).toList();
  }
}
