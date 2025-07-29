// lib/providers/team_provider.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/team.dart';
import '../models/todo.dart';

class TeamProvider with ChangeNotifier {
  // ... (kode yang ada) ...
  // Tambahkan konstruktor ini
  TeamProvider(); 
  // ...

  final ApiService _apiService = ApiService();
  String? _authToken;

  List<Team> _teams = [];
  List<Todo> _currentTodos = [];
  bool _isLoading = false;

  List<Team> get teams => _teams;
  List<Todo> get currentTodos => _currentTodos;
  bool get isLoading => _isLoading;

  // Metode untuk menerima token dari AuthProvider
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  Future<void> fetchAndSetTeams() async {
  // TAMBAHKAN PRINT INI
  print('Mencoba mengambil data tim...');
  print('Token yang tersedia saat ini: $_authToken');

  if (_authToken == null) {
    print('Gagal: Token null. Fetch dibatalkan.');
    return;
  }
  _isLoading = true;
  notifyListeners();

  try {
    _teams = await _apiService.getMyTeams(_authToken!);
    // TAMBAHKAN PRINT INI
    print('Berhasil: Ditemukan ${_teams.length} tim.');
  } catch (error) {
    print('Error saat mengambil tim: $error');
  }
  _isLoading = false;
  notifyListeners();
}


  Future<void> fetchAndSetTodos(int teamId) async {
    if (_authToken == null) return;
    _isLoading = true;
    _currentTodos = []; // Kosongkan list sebelumnya
    notifyListeners();

    try {
      _currentTodos = await _apiService.getTeamTodos(_authToken!, teamId);
    } catch (error) {
      print(error);
    }
    _isLoading = false;
    notifyListeners();
  }
}