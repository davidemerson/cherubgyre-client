import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/security_utils.dart';
import '../core/utils/session_manager.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;
  String _username = '';
  bool _isPinVisible = false;
  bool _isReturningUser = false;
  bool _isDuressLogin = false;

  LoginViewModel() 
    : _apiClient = ApiClient() {
    _initializeUser();
  }

  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  String get username => _username;
  bool get isPinVisible => _isPinVisible;
  bool get isReturningUser => _isReturningUser;
  bool get isDuressLogin => _isDuressLogin;

  Future<void> _initializeUser() async {
    try {
      // Check if user has previously logged in
      final userData = await SessionManager.getUserData();
      if (userData != null && userData['username'] != null) {
        _username = userData['username'] as String;
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

  String? validatePin(String pin) {
    if (pin.isEmpty) {
      return 'PIN is required';
    }
    if (!SecurityUtils.isValidPinFormat(pin)) {
      return 'PIN must be at least 6 digits';
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String pin) async {
    debugPrint('🔐 LoginViewModel.login() called with username: $_username, pin length: ${pin.length}');
    
    final usernameError = validateUsername();
    final pinError = validatePin(pin);
    
    if (usernameError != null || pinError != null) {
      debugPrint('❌ Validation failed - usernameError: $usernameError, pinError: $pinError');
      _error = usernameError ?? pinError;
      notifyListeners();
      return {'success': false, 'isDuress': false};
    }

    try {
      debugPrint('🔄 Setting loading state to true');
      _isLoading = true;
      _error = null;
      notifyListeners();
      debugPrint('✅ Loading state updated, notifying listeners');

      debugPrint('📡 Calling API client login...');
      // Call API to authenticate user
      final response = await _apiClient.login(username: _username, pin: pin);
      debugPrint('📡 API response received: $response');
      
      if (response[ApiConstants.successKey] == true) {
        debugPrint('✅ Login successful, checking if duress...');
        
        // Check if this is a duress login
        _isDuressLogin = response['is_duress'] == true;
        debugPrint('🚨 Is duress login: $_isDuressLogin');
        
        // Store authentication data securely
        await SessionManager.storeToken(response[ApiConstants.tokenKey]);
        await SessionManager.storeUserData({'username': _username});
        await SessionManager.storeLastLogin();
        
        // Securely clear the PIN from memory
        SecurityUtils.secureClear(pin);
        debugPrint('✅ Session data stored, PIN cleared');
        
        return {'success': true, 'isDuress': _isDuressLogin};
      } else {
        debugPrint('❌ Login failed: ${response[ApiConstants.messageKey]}');
        _error = response[ApiConstants.messageKey] ?? 'Login failed';
        // Securely clear the PIN from memory even on failure
        SecurityUtils.secureClear(pin);
        return {'success': false, 'isDuress': false};
      }
    } catch (e) {
      debugPrint('💥 Login exception: $e');
      _error = 'Network error. Please try again.';
      // Securely clear the PIN from memory even on error
      SecurityUtils.secureClear(pin);
      return {'success': false, 'isDuress': false};
    } finally {
      debugPrint('🔄 Setting loading state to false');
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ Loading state updated, notifying listeners');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSavedUser() async {
    await SessionManager.clearSession();
    _username = '';
    _isReturningUser = false;
    notifyListeners();
  }
} 