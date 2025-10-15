import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:noviindus/models/login_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  LoginResponse? _user;

  String _selectedCode = '+91';
  bool _isLoading = false;

  // Getters
  String get selectedCode => _selectedCode;
  bool get isLoading => _isLoading;
  LoginResponse? get user => _user;
  bool get isLoggedIn => _user != null && _user!.accessToken.isNotEmpty;

  void updateCountryCode(String code) {
    _selectedCode = code;
    notifyListeners();
  }

  // Load user from SharedPreferences
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final jsonData = jsonDecode(userData);
      _user = LoginResponse.fromJson(jsonData);
      notifyListeners();
    }
  }

  // Clear user data (logout)
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Logged out")));
  }

  // Login via OTP
  Future<void> login(
    String countryCode,
    String phone,
    BuildContext context,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(countryCode, phone);

      if (response != null && response.accessToken.isNotEmpty) {
        _user = response;

        // Save user in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(response.toJson()));

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Unauthorized or missing token
        await logout(context);
      }
    } on HttpException catch (e) {
      String message;
      switch (e.code) {
        case 400:
          message = "Invalid request or wrong phone number";
          break;
        case 401:
          message = "Unauthorized access, please login again";
          await logout(context);
          break;
        case 500:
          message = "Internal server error, please try again later";
          break;
        default:
          message = e.message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unexpected error: $e")));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
