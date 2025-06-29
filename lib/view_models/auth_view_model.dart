import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum PinType { normal, duress }

class AuthViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  
  bool _isLoading = false;
  String? _error;
  String _pin = '';
  bool _isPinVisible = false;
  PinType? _pinType;

  AuthViewModel() : _storage = const FlutterSecureStorage();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get pin => _pin;
  bool get isPinVisible => _isPinVisible;
  PinType? get pinType => _pinType;

  void setPin(String value) {
    _pin = value;
    _error = null;
    _pinType = null;
    notifyListeners();
  }

  void togglePinVisibility() {
    _isPinVisible = !_isPinVisible;
    notifyListeners();
  }

  String? validatePin() {
    if (_pin.isEmpty) {
      return 'PIN is required';
    }
    if (_pin.length < 4) {
      return 'PIN must be at least 4 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(_pin)) {
      return 'PIN must contain only numbers';
    }
    return null;
  }

  Future<void> verifyPin() async {
    final validationError = validatePin();
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get stored PINs from secure storage
      final normalPin = await _storage.read(key: 'normalPin');
      final duressPin = await _storage.read(key: 'duressPin');

      // Determine PIN type
      if (normalPin == _pin) {
        _pinType = PinType.normal;
      } else if (duressPin == _pin) {
        _pinType = PinType.duress;
      } else {
        _error = 'Invalid PIN. Please try again.';
      }

    } catch (e) {
      _error = 'An error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _pin = '';
    _error = null;
    _pinType = null;
    _isPinVisible = false;
    notifyListeners();
  }
} 