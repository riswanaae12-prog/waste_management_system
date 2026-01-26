import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isCitizen => _user?.userType == 'citizen';
  bool get isDriver => _user?.userType == 'driver';

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Always log out any existing user on app start.
      await _authService.logoutUser();
      _user = null;
      _isAuthenticated = false;
    } catch (e) {
      print("Error during initial logout: $e"); // Debug print
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.registerUser(
        email: email,
        password: password,
        name: name,
        phone: phone,
        userType: userType,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        notifyListeners();
        return null; // Success
      }
      return "An unknown error occurred during registration.";
    } catch (e) {
      print("Registration error: $e"); // Debug print
      _error = e.toString();
      notifyListeners();
      return _error; // Failure, return the error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.loginUser(
        email: email,
        password: password,
        userType: userType,
      );

      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        notifyListeners();
        return null; // Success
      }
       return "An unknown error occurred after login.";
    } catch (e) {
      print("Login error: $e"); // Debug print
      _error = e.toString();
      notifyListeners();
      return _error; // Failure, return the error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> logout() async {
    try {
      await _authService.logoutUser();
      _user = null;
      _isAuthenticated = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
    String? gender,
    int? age,
  }) async {
    if (_user == null) return false;

    try {
      await _authService.updateUserProfile(
        userId: _user!.id,
        name: name,
        phone: phone,
        profileImage: profileImage,
        gender: gender,
        age: age,
      );

      _user = _user?.copyWith(
        name: name,
        phone: phone,
        profileImage: profileImage,
        gender: gender,
        age: age,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
