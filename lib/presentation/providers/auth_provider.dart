import 'package:flutter/material.dart';
import '../../data/datasources/prefs_datasource.dart';

class AuthProvider extends ChangeNotifier {
  final PrefsDataSource _prefs;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  String _userEmail = '';
  String _userName = '';

  AuthProvider(this._prefs) {
    _isLoggedIn = _prefs.isLoggedIn;
    _userEmail = _prefs.userEmail;
    _userName = _prefs.userName;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  String get userName => _userName;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock validation
    if (password.length < 6) {
      _errorMessage = 'Invalid credentials. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock success
    _isLoggedIn = true;
    _userEmail = email;
    _userName = email.split('@').first;
    _userName = _userName[0].toUpperCase() + _userName.substring(1);

    await _prefs.setLoggedIn(true);
    await _prefs.setUserEmail(email);
    await _prefs.setUserName(_userName);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = '';
    _userName = '';
    await _prefs.setLoggedIn(false);
    await _prefs.setUserEmail('');
    await _prefs.setUserName('');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
