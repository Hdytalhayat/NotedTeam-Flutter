// lib/api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Ganti dengan IP yang sesuai jika perlu
  final String _baseUrl = 'https://noble-energy-production-d0ae.up.railway.app'; 

  Future<void> register(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      // Mengambil pesan error dari body response jika ada
      final errorData = json.decode(response.body);
      throw Exception('Gagal mendaftar: ${errorData['error']}');
    }
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Gagal login: ${errorData['error']}');
    }
  }
}