import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'security_utils.dart';

/// Secure PIN manager that handles PIN storage and verification
/// without keeping PINs in memory longer than necessary
class PinManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // Private constructor to prevent instantiation
  PinManager._();

  /// Store a PIN securely with salt and hash
  static Future<void> storePin(String pin, String key) async {
    if (!SecurityUtils.isValidPinFormat(pin)) {
      throw ArgumentError('Invalid PIN format');
    }

    final salt = SecurityUtils.generateSalt();
    final hashedPin = SecurityUtils.hashPin(pin, salt);
    
    // Store hash and salt separately
    await _storage.write(key: '${key}_hash', value: hashedPin);
    await _storage.write(key: '${key}_salt', value: salt);
    
    // Securely clear the PIN from memory
    SecurityUtils.secureClear(pin);
  }

  /// Verify a PIN against stored hash
  static Future<bool> verifyPin(String pin, String key) async {
    if (!SecurityUtils.isValidPinFormat(pin)) {
      return false;
    }

    try {
      // Retrieve stored hash and salt
      final storedHash = await _storage.read(key: '${key}_hash');
      final storedSalt = await _storage.read(key: '${key}_salt');
      
      if (storedHash == null || storedSalt == null) {
        return false;
      }

      // Hash the provided PIN with stored salt
      final hashedPin = SecurityUtils.hashPin(pin, storedSalt);
      
      // Use constant-time comparison
      final isValid = SecurityUtils.constantTimeEquals(hashedPin, storedHash);
      
      // Securely clear the PIN from memory
      SecurityUtils.secureClear(pin);
      
      return isValid;
    } catch (e) {
      // Securely clear the PIN from memory even on error
      SecurityUtils.secureClear(pin);
      return false;
    }
  }

  /// Check if a PIN exists for the given key
  static Future<bool> hasPin(String key) async {
    final hash = await _storage.read(key: '${key}_hash');
    return hash != null;
  }

  /// Delete a stored PIN
  static Future<void> deletePin(String key) async {
    await _storage.delete(key: '${key}_hash');
    await _storage.delete(key: '${key}_salt');
  }

  /// Clear all stored PINs (for logout/security)
  static Future<void> clearAllPins() async {
    await _storage.deleteAll();
  }
} 