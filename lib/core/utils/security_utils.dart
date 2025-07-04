import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// Security utilities for PIN handling and sensitive data management
class SecurityUtils {
  // Private constructor to prevent instantiation
  SecurityUtils._();

  /// Generate a cryptographically secure random salt
  static String generateSalt() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  /// Hash a PIN with salt using SHA-256
  static String hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Constant-time comparison to prevent timing attacks
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Securely clear a string from memory by overwriting it
  static void secureClear(String? value) {
    if (value == null) return;
    
    // Create a mutable copy and overwrite it
    final bytes = utf8.encode(value);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }

  /// Validate PIN format (numbers only, 4-6 digits)
  static bool isValidPinFormat(String pin) {
    return RegExp(r'^[0-9]{4,6}$').hasMatch(pin);
  }

  /// Generate a secure random PIN for testing (if needed)
  static String generateSecurePin() {
    final random = Random.secure();
    final digits = List.generate(4, (_) => random.nextInt(10));
    return digits.join();
  }
} 