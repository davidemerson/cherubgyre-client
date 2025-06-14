import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/location_data.dart';
import '../models/duress_settings.dart';

class AppState extends ChangeNotifier {
  UserProfile? _currentUser;
  DuressSettings? _duressSettings;
  List<LocationData> _followedUsersLocations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get currentUser => _currentUser;
  DuressSettings? get duressSettings => _duressSettings;
  List<LocationData> get followedUsersLocations => _followedUsersLocations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Setters
  void setCurrentUser(UserProfile? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setDuressSettings(DuressSettings settings) {
    _duressSettings = settings;
    notifyListeners();
  }

  void setFollowedUsersLocations(List<LocationData> locations) {
    _followedUsersLocations = locations;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Helper methods
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _currentUser = null;
    _duressSettings = null;
    _followedUsersLocations = [];
    _error = null;
    notifyListeners();
  }
} 