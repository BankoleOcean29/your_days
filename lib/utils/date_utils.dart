import 'package:intl/intl.dart';

abstract class AppDateUtils {
  /// Day number within the year (Jan 1 = 1, Dec 31 = 365 or 366).
  static int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  /// Total days in [year] — 366 on leap years, 365 otherwise.
  static int totalDaysInYear(int year) {
    return DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1;
  }

  /// Simple week number (1-53), Week 1 starts on Jan 1.
  static int weekOfYear(DateTime date) {
    return ((dayOfYear(date) - 1) ~/ 7) + 1;
  }

  /// Calendar quarter (1–4).
  static int currentQuarter(DateTime date) {
    return ((date.month - 1) ~/ 3) + 1;
  }

  /// Approximate whole weeks remaining in the year.
  static int weeksRemainingInYear(DateTime date) {
    final totalDays = totalDaysInYear(date.year);
    final remaining = totalDays - dayOfYear(date);
    return (remaining / 7).floor();
  }

  /// Full calendar months remaining (not counting the current month).
  static int monthsRemainingInYear(DateTime date) {
    return (12 - date.month).clamp(0, 11);
  }

  /// "Tuesday, January 14" format.
  static String formatFull(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  /// "Jan 14, 2026" format.
  static String formatShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// "YYYY-MM-DD" for storage keys.
  static String toStorageKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Build a [DateTime] for a given 1-based day-of-year in [year].
  static DateTime fromDayOfYear(int year, int dayNumber) {
    return DateTime(year, 1, 1).add(Duration(days: dayNumber - 1));
  }
}
