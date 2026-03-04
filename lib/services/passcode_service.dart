import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:your_days/services/preferences_service.dart';
import 'package:your_days/utils/constants.dart';

class PasscodeService {
  PasscodeService._();
  static final PasscodeService instance = PasscodeService._();

  /// The decrypted PIN held in memory while the journal session is active.
  /// Cleared on lock.
  String? _sessionPin;

  bool get isUnlocked => _sessionPin != null;
  String? get sessionPin => _sessionPin;

  // ── PIN management ─────────────────────────────────────────────────────────

  String _hashPin(String pin) {
    final hash = crypto.sha256.convert(utf8.encode(pin)).bytes;
    return base64Encode(Uint8List.fromList(hash));
  }

  /// Returns true if [pin] matches the stored hash.
  bool verifyPin(String pin) {
    final stored = PreferencesService.instance.pinHash;
    if (stored == null) return false;
    return _hashPin(pin) == stored;
  }

  /// Saves the new PIN hash to preferences.
  void savePin(String pin) {
    PreferencesService.instance.pinHash = _hashPin(pin);
  }

  /// Clears the PIN hash (and all journal entries must be wiped by caller).
  void clearPin() {
    PreferencesService.instance.pinHash = null;
    lock();
  }

  // ── Session ────────────────────────────────────────────────────────────────

  void unlock(String pin) {
    _sessionPin = pin;
    PreferencesService.instance.sessionUnlockedAt =
        DateTime.now().millisecondsSinceEpoch;
  }

  void lock() {
    _sessionPin = null;
    PreferencesService.instance.sessionUnlockedAt = null;
  }

  /// Call on app resume. Returns true if the session was locked due to timeout.
  bool checkAndLockIfExpired() {
    if (_sessionPin == null) return false; // already locked
    final unlockedAt = PreferencesService.instance.sessionUnlockedAt;
    if (unlockedAt == null) {
      lock();
      return true;
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch - unlockedAt;
    if (elapsed > AppConstants.kSessionLockMinutes * 60 * 1000) {
      lock();
      return true;
    }
    return false;
  }

  /// Update the session timestamp (call when user actively uses journal).
  void refreshSession() {
    if (_sessionPin != null) {
      PreferencesService.instance.sessionUnlockedAt =
          DateTime.now().millisecondsSinceEpoch;
    }
  }
}
