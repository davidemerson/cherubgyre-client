import 'package:flutter/foundation.dart';
import '../services/register_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService;
  
  bool _isLoading = false;
  String? _error;
  String? _inviteCode;
  String? _normalPin;
  String? _confirmNormalPin;
  String? _duressPin;
  String? _confirmDuressPin;
  bool _acceptedPrivacyPolicy = false;
  Map<String, dynamic>? _userData;

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
  String? get normalPin => _normalPin;
  String? get confirmNormalPin => _confirmNormalPin;
  String? get duressPin => _duressPin;
  String? get confirmDuressPin => _confirmDuressPin;
  bool get acceptedPrivacyPolicy => _acceptedPrivacyPolicy;
  Map<String, dynamic>? get userData => _userData;

  void setInviteCode(String code) {
    // Convert to uppercase and remove any spaces for consistency
    _inviteCode = code.toUpperCase().replaceAll(' ', '');
    _error = null;
    notifyListeners();
  }

  void setNormalPin(String pin) {
    _normalPin = pin;
    _error = null;
    notifyListeners();
  }

  void setConfirmNormalPin(String pin) {
    _confirmNormalPin = pin;
    _error = null;
    notifyListeners();
  }

  void setDuressPin(String pin) {
    _duressPin = pin;
    _error = null;
    notifyListeners();
  }

  void setConfirmDuressPin(String pin) {
    _confirmDuressPin = pin;
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

  String? validateInviteCode() {
    final inviteCode = _inviteCode;
    if (inviteCode == null || inviteCode.isEmpty) {
      return 'Invite code is required';
    }
    
    // Check if invite code contains only alphanumeric characters
    final alphanumericRegex = RegExp(r'^[A-Z0-9]+$');
    if (!alphanumericRegex.hasMatch(inviteCode)) {
      return 'Invite code can only contain letters and numbers';
    }
    
    // Check minimum length (adjust as needed)
    if (inviteCode.length < 4) {
      return 'Invite code must be at least 4 characters';
    }
    
    // Check maximum length (adjust as needed)
    if (inviteCode.length > 20) {
      return 'Invite code cannot exceed 20 characters';
    }
    
    return null;
  }

  String? validateNormalPin() {
    final normalPin = _normalPin;
    final confirmNormalPin = _confirmNormalPin;
    
    if (normalPin == null || confirmNormalPin == null) {
      return 'Both fields are required';
    }
    if (normalPin != confirmNormalPin) {
      return 'PINs do not match';
    }
    if (normalPin.length < 4) {
      return 'PIN must be at least 4 digits';
    }
    return null;
  }

  String? validateDuressPin() {
    final duressPin = _duressPin;
    final confirmDuressPin = _confirmDuressPin;
    final normalPin = _normalPin;
    
    if (duressPin == null || confirmDuressPin == null) {
      return 'Both fields are required';
    }
    if (duressPin != confirmDuressPin) {
      return 'PINs do not match';
    }
    if (duressPin.length < 4) {
      return 'PIN must be at least 4 digits';
    }
    if (normalPin != null && duressPin == normalPin) {
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
    final validationError = validateInviteCode();
    if (validationError != null) {
      _error = validationError;
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

      final isValid = await _registerService.verifyInviteCode(inviteCode);
      
      if (!isValid) {
        _error = 'Invalid or expired invite code';
      }

      return isValid;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register() async {
    final pinError = validateNormalPin();
    final duressError = validateDuressPin();
    final privacyError = validatePrivacyPolicy();
    
    if (pinError != null || duressError != null || privacyError != null) {
      _error = pinError ?? duressError ?? privacyError;
      notifyListeners();
      return false;
    }

    final inviteCode = _inviteCode;
    final normalPin = _normalPin;
    final duressPin = _duressPin;

    if (inviteCode == null || normalPin == null || duressPin == null) {
      _error = 'All required fields must be completed';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userData = await _registerService.register(
        inviteCode: inviteCode,
        normalPin: normalPin,
        duressPin: duressPin,
      );

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 