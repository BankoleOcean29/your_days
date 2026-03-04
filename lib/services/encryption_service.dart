import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:encrypt/encrypt.dart';

/// AES-256-CBC encryption with a PIN-derived key.
///
/// Security note: a 4-digit PIN has a tiny key space (10,000 combinations).
/// Do not use this as the sole security mechanism for sensitive data. The PIN
/// protects against casual access; it does not protect against a motivated
/// attacker with physical device access.
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  Key _keyFromPin(String pin) {
    final hash = crypto.sha256.convert(utf8.encode(pin)).bytes;
    return Key(Uint8List.fromList(hash)); // 32 bytes → AES-256
  }

  /// Encrypts [plaintext] and returns `"<iv_base64>:<ciphertext_base64>"`.
  String encrypt(String plaintext, String pin) {
    final key = _keyFromPin(pin);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a value produced by [encrypt]. Returns null on failure
  /// (wrong PIN or corrupt data).
  String? decrypt(String ciphertext, String pin) {
    try {
      final parts = ciphertext.split(':');
      if (parts.length != 2) return null;
      final iv = IV.fromBase64(parts[0]);
      final key = _keyFromPin(pin);
      final encrypter = Encrypter(AES(key));
      return encrypter.decrypt64(parts[1], iv: iv);
    } catch (_) {
      return null;
    }
  }
}
