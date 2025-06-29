import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_client.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  String _username = '';
  String _pin = '';
  bool _isPinVisible = false;
  bool _isReturningUser = false;

  LoginViewModel() 
    : _apiClient = ApiClient(),
      _storage = const FlutterSecureStorage() {
    _initializeUser();
  }

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  String get username => _username;
  String get pin => _pin;
  bool get isPinVisible => _isPinVisible;
  bool get isReturningUser => _isReturningUser;

  Future<void> _initializeUser() async {
    try {
      // Check if user has previously logged in
      final savedUsername = await _storage.read(key: 'username');
      if (savedUsername != null && savedUsername.isNotEmpty) {
        _username = savedUsername;
        _isReturningUser = true;
      }
    } catch (e) {
      debugPrint('Error loading saved username: $e');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setUsername(String value) {
    _username = value.trim();
    _error = null;
    notifyListeners();
  }

  void setPin(String value) {
    _pin = value;
    _error = null;
    notifyListeners();
  }

  void togglePinVisibility() {
    _isPinVisible = !_isPinVisible;
    notifyListeners();
  }

  String? validateUsername() {
    if (_username.isEmpty) {
      return 'Username is required';
    }
    if (_username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
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

  Future<bool> login() async {
    final usernameError = validateUsername();
    final pinError = validatePin();
    
    if (usernameError != null || pinError != null) {
      _error = usernameError ?? pinError;
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Call API to authenticate user
      final response = await _apiClient.login(username: _username, pin: _pin);
      
      if (response['success'] == true) {
        // Store authentication token and username
        await _storage.write(key: 'accessToken', value: response['token']);
        await _storage.write(key: 'username', value: _username);
        
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _error = 'Network error. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSavedUser() async {
    await _storage.delete(key: 'username');
    _username = '';
    _isReturningUser = false;
    notifyListeners();
  }
} 