// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  final AuthService _authService = AuthService();

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name, email, password);
  }

  Future<void> login(String email, String password) async {
    try {
      final token = await _authService.login(email, password);
      _token = token;
      
      // Simpan token ke perangkat
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      
      notifyListeners(); // Beri tahu UI bahwa state berubah
    } catch (error) {
      rethrow; // Lemparkan lagi error agar bisa ditangkap di UI
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return;
    }
    _token = prefs.getString('authToken');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    notifyListeners();
  }
}