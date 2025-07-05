import 'package:flutter/foundation.dart';
import '../services/register_service.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/security_utils.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService;
  
  bool _isLoading = false;
  String? _error;
  String? _inviteCode;
  bool _acceptedPrivacyPolicy = false;
  Map<String, dynamic>? _userData;
  
  // Server-assigned data
  String? _assignedUsername;
  String? _assignedAvatar;

  // Temporary storage for PINs during registration flow
  String? _normalPin;
  String? _duressPin;

  // Registration step state
  int _step = 0;
  int get step => _step;
  void nextStep() {
    _step++;
    notifyListeners();
  }
  void prevStep() {
    if (_step > 0) {
      _step--;
      notifyListeners();
    }
  }
  void resetSteps() {
    _step = 0;
    notifyListeners();
  }

  RegisterViewModel() : _registerService = RegisterService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get inviteCode => _inviteCode;
  bool get acceptedPrivacyPolicy => _acceptedPrivacyPolicy;
  Map<String, dynamic>? get userData => _userData;
  String? get assignedUsername => _assignedUsername;
  String? get assignedAvatar => _assignedAvatar;
  String? get normalPin => _normalPin;

  void setInviteCode(String code) {
    // Remove any spaces and normalize the invite code
    _inviteCode = code.trim().replaceAll(' ', '');
    _error = null;
    notifyListeners();
  }

  void setPrivacyPolicyAccepted(bool accepted) {
    _acceptedPrivacyPolicy = accepted;
    _error = null;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setNormalPin(String pin) {
    _normalPin = pin;
    _error = null;
    notifyListeners();
  }

  void setDuressPin(String pin) {
    _duressPin = pin;
    _error = null;
    notifyListeners();
  }

  void clearPins() {
    SecurityUtils.secureClear(_normalPin);
    SecurityUtils.secureClear(_duressPin);
    _normalPin = null;
    _duressPin = null;
  }

  String? validateInviteCode() {
    final inviteCode = _inviteCode;
    if (inviteCode == null || inviteCode.isEmpty) {
      return 'Invite code is required';
    }
    
    // Let the server handle all validation - just check if it's not empty
    return null;
  }

  String? validateNormalPin(String normalPin, String confirmNormalPin) {
    if (normalPin.isEmpty || confirmNormalPin.isEmpty) {
      return 'Both fields are required';
    }
    if (normalPin != confirmNormalPin) {
      return 'PINs do not match';
    }
    if (!SecurityUtils.isValidPinFormat(normalPin)) {
      return 'PIN must be exactly 6 characters (letters and numbers)';
    }
    return null;
  }

  String? validateDuressPin(String duressPin, String confirmDuressPin, String normalPin) {
    if (duressPin.isEmpty || confirmDuressPin.isEmpty) {
      return 'Both fields are required';
    }
    if (duressPin != confirmDuressPin) {
      return 'PINs do not match';
    }
    if (!SecurityUtils.isValidPinFormat(duressPin)) {
      return 'PIN must be exactly 6 characters (letters and numbers)';
    }
    if (normalPin.isNotEmpty && duressPin == normalPin) {
      return 'Duress PIN cannot be the same as your normal PIN';
    }
    return null;
  }

  String? validatePrivacyPolicy() {
    if (!_acceptedPrivacyPolicy) {
      return 'You must accept the Privacy Policy and Terms & Conditions to continue';
    }
    return null;
  }

  Future<bool> verifyInviteCode() async {
    final inviteCode = _inviteCode;
    if (inviteCode == null || inviteCode.isEmpty) {
      _error = 'Invite code is required';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('🔍 RegisterViewModel: Verifying invite code: $inviteCode');
      }

      // Let the server handle all validation
      final isValid = await _registerService.verifyInviteCode(inviteCode);
      
      if (kDebugMode) {
        debugPrint('🔍 RegisterViewModel: Invite code verification result: $isValid');
      }
      
      if (!isValid) {
        _error = 'Invalid or expired invite code';
        if (kDebugMode) {
          debugPrint('❌ RegisterViewModel: Invite code validation failed');
        }
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 RegisterViewModel: Exception during invite code verification: $e');
        debugPrint('💥 RegisterViewModel: Exception type: ${e.runtimeType}');
        debugPrint('💥 RegisterViewModel: Exception stack trace: ${StackTrace.current}');
      }
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register() async {
    // Use stored PINs if provided, otherwise use the temporary stored ones
    final normalPin = _normalPin;
    final duressPin = _duressPin;
    
    if (normalPin == null || duressPin == null) {
      _error = 'PINs are required';
      notifyListeners();
      return false;
    }
    
    final pinError = validateNormalPin(normalPin, normalPin);
    final duressError = validateDuressPin(duressPin, duressPin, normalPin);
    final privacyError = validatePrivacyPolicy();
    
    if (pinError != null || duressError != null || privacyError != null) {
      _error = pinError ?? duressError ?? privacyError;
      notifyListeners();
      return false;
    }

    final inviteCode = _inviteCode;
    if (inviteCode == null) {
      _error = 'Invite code is required';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('🔍 RegisterViewModel: Starting registration...');
        debugPrint('🔍 RegisterViewModel: Invite code: $inviteCode');
        debugPrint('🔍 RegisterViewModel: Normal PIN length: ${normalPin.length}');
        debugPrint('🔍 RegisterViewModel: Duress PIN length: ${duressPin.length}');
      }

      _userData = await _registerService.register(
        inviteCode: inviteCode,
        normalPin: normalPin,
        duressPin: duressPin,
      );

      if (kDebugMode) {
        debugPrint('🔍 RegisterViewModel: Registration successful, user data: $_userData');
      }

      // Extract server-assigned username and avatar
      if (_userData != null) {
        _assignedUsername = _userData![ApiConstants.usernameKey] as String?;
        _assignedAvatar = _userData![ApiConstants.avatarKey] as String?;
        
        if (kDebugMode) {
          debugPrint('🔍 RegisterViewModel: Assigned username: $_assignedUsername');
          debugPrint('🔍 RegisterViewModel: Assigned avatar: $_assignedAvatar');
        }
      }

      // Clear PINs from memory after successful registration
      clearPins();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('💥 RegisterViewModel: Exception during registration: $e');
        debugPrint('💥 RegisterViewModel: Exception type: ${e.runtimeType}');
        debugPrint('💥 RegisterViewModel: Exception stack trace: ${StackTrace.current}');
      }
      _error = e.toString();
      // Clear PINs from memory even on error
      clearPins();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 