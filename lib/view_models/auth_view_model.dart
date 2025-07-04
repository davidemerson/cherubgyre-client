import 'package:flutter/foundation.dart';
import '../core/utils/session_manager.dart';

/// Simple auth state provider - only tracks if user is authenticated
/// This is the only auth-related global provider
class AuthViewModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;

  AuthViewModel() {
    checkAuthStatus();
  }

  /// Check if user is authenticated on app startup
  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      _isAuthenticated = await SessionManager.isAuthenticated();
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isAuthenticated = false;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  /// Update auth status after login
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  /// Logout user
  Future<void> logout() async {
    await SessionManager.clearSession();
    _isAuthenticated = false;
    notifyListeners();
  }
} 