import 'package:flutter/foundation.dart';
import '../core/utils/session_manager.dart';

/// Simple auth state provider - only tracks if user is authenticated
/// This is the only auth-related global provider
class AuthViewModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isCheckingAuth = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;

  AuthViewModel();

  /// Check if user is authenticated on app startup
  Future<void> checkAuthStatus() async {
    if (kDebugMode) {
      debugPrint('🔍 AuthViewModel: Starting auth check...');
    }
    
    _isCheckingAuth = true;
    notifyListeners();

    // Ensure minimum splash duration for auth check
    final startTime = DateTime.now();
    const minimumSplashDuration = Duration(milliseconds: 2500);

    try {
      _isAuthenticated = await SessionManager.isAuthenticated();
      if (kDebugMode) {
        debugPrint('🔍 AuthViewModel: Auth check result: isAuthenticated = $_isAuthenticated');
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _isAuthenticated = false;
    }
    
    // Ensure minimum splash duration before completing
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minimumSplashDuration) {
      final remainingTime = minimumSplashDuration - elapsedTime;
      if (kDebugMode) {
        debugPrint('🔍 AuthViewModel: Waiting ${remainingTime.inMilliseconds}ms to complete minimum splash duration');
      }
      await Future.delayed(remainingTime);
    }
    
    _isCheckingAuth = false;
    if (kDebugMode) {
      debugPrint('🔍 AuthViewModel: Auth check completed, isCheckingAuth = $_isCheckingAuth');
    }
    notifyListeners();
  }

  /// Update auth status after login
  void setAuthenticated(bool value) {
    if (_isAuthenticated != value) {
      _isAuthenticated = value;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    await SessionManager.clearSession();
    if (_isAuthenticated) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
} 