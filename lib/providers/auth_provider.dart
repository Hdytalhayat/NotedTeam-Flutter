// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AuthProvider with ChangeNotifier {
  String? _token;
  final AuthService _authService = AuthService();

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> register(String name, String email, String password) async {
    // Pindahkan pemanggilan service ke sini
    final url = Uri.parse('https://noble-energy-production-d0ae.up.railway.app/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      // Cek jika body kosong SEBELUM mencoba decode
      if (response.body.isEmpty) {
        throw Exception('Received empty response from server.');
      }
      
      final responseData = json.decode(response.body);

      if (response.statusCode >= 400) {
        throw Exception(responseData['error'] ?? 'An unknown error occurred.');
      }
      // Jika sukses, tidak melakukan apa-apa karena tidak ada state yang perlu diubah
    } catch (error) {
      // Lemparkan lagi agar UI bisa menangkapnya
      rethrow;
    }
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