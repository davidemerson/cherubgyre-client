import 'package:flutter/foundation.dart';
import '../core/utils/session_manager.dart';
import '../services/api_client.dart';
import '../core/constants/api_constants.dart';

class MainPageViewModel extends ChangeNotifier {
  final ApiClient _apiClient;
  String? _username;
  String? _avatar;
  bool _isLoading = true;
  String? _error;

  String? get username => _username;
  String? get avatar => _avatar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MainPageViewModel() : _apiClient = ApiClient() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('🔍 MainPageViewModel: Loading user data...');
      }

      final userData = await SessionManager.getUserData();
      
      if (kDebugMode) {
        debugPrint('🔍 MainPageViewModel: User data loaded: $userData');
      }

      _username = userData?['username'];
      _avatar = userData?['avatar'];
      
      if (kDebugMode) {
        debugPrint('🔍 MainPageViewModel: Username: $_username, Avatar: $_avatar');
      }

      // If avatar is not available from session, try to fetch from profile API
      if (_username != null && (_avatar == null || _avatar!.isEmpty)) {
        if (kDebugMode) {
          debugPrint('🔍 MainPageViewModel: Avatar not found in session, fetching from profile API...');
        }
        
        try {
          final profileResponse = await _apiClient.getProfile();
          
          if (kDebugMode) {
            debugPrint('🔍 MainPageViewModel: Profile API response: $profileResponse');
          }
          
          if (profileResponse[ApiConstants.successKey] == true) {
            final profileUserData = profileResponse[ApiConstants.userKey] as Map<String, dynamic>?;
            if (kDebugMode) {
              debugPrint('🔍 MainPageViewModel: Profile user data: $profileUserData');
            }
            
            if (profileUserData != null && profileUserData[ApiConstants.avatarKey] != null) {
              _avatar = profileUserData[ApiConstants.avatarKey] as String;
              
              // Update session with the fetched avatar
              await SessionManager.storeUserData({
                'username': _username,
                'avatar': _avatar,
              });
              
              if (kDebugMode) {
                debugPrint('🔍 MainPageViewModel: Avatar fetched from profile API: $_avatar');
                debugPrint('🔍 MainPageViewModel: Updated session with avatar');
              }
            } else {
              if (kDebugMode) {
                debugPrint('⚠️ MainPageViewModel: No avatar found in profile user data');
              }
            }
          } else {
            if (kDebugMode) {
              debugPrint('⚠️ MainPageViewModel: Profile API call failed: ${profileResponse[ApiConstants.messageKey]}');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ MainPageViewModel: Error fetching profile: $e');
          }
          // Don't set error for profile fetch failure, just continue without avatar
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 MainPageViewModel: Error loading user data: $e');
      }
      _error = 'Failed to load user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
} 