import 'package:flutter/material.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  bool _isLoggedIn = false;
  String _username = '';
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _api.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.login(username, password);
      if (result.containsKey('error')) { _isLoading = false; notifyListeners(); return false; }
      _isLoggedIn = true;
      _username = username;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) { _isLoading = false; notifyListeners(); return false; }
  }

  Future<void> logout() async {
    await _api.logout();
    _isLoggedIn = false;
    _username = '';
    notifyListeners();
  }
}
