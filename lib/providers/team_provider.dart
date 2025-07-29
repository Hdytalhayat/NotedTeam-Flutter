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
  Future<void> createTeam(String name) async {
    if (_authToken == null) return;
    try {
      final newTeam = await _apiService.createTeam(_authToken!, name);
      _teams.add(newTeam);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> createTodo(int teamId, String title, String description) async {
    if (_authToken == null) return;
    try {
      final newTodo = await _apiService.createTodo(_authToken!, teamId, title, description);
      _currentTodos.insert(0, newTodo); // Tambahkan di awal list
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateTodoStatus(int teamId, int todoId, String newStatus) async {
    if (_authToken == null) return;
    try {
      await _apiService.updateTodoStatus(_authToken!, teamId, todoId, newStatus);
      // Perbarui state lokal
      final todoIndex = _currentTodos.indexWhere((todo) => todo.id == todoId);
      if (todoIndex >= 0) {
        // Buat objek baru agar listener tahu ada perubahan
        final oldTodo = _currentTodos[todoIndex];
        _currentTodos[todoIndex] = Todo(
          id: oldTodo.id,
          title: oldTodo.title,
          description: oldTodo.description,
          status: newStatus, // Status baru
          urgency: oldTodo.urgency,
          teamId: oldTodo.teamId,
        );
        notifyListeners();
      }
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> deleteTodo(int teamId, int todoId) async {
    if (_authToken == null) return;
    
    // Hapus dari UI terlebih dahulu untuk respons yang cepat (Optimistic Deleting)
    final existingTodoIndex = _currentTodos.indexWhere((todo) => todo.id == todoId);
    var existingTodo = _currentTodos[existingTodoIndex];
    _currentTodos.removeAt(existingTodoIndex);
    notifyListeners();

    try {
      await _apiService.deleteTodo(_authToken!, teamId, todoId);
    } catch (error) {
      // Jika gagal, kembalikan item yang dihapus ke UI
      _currentTodos.insert(existingTodoIndex, existingTodo);
      notifyListeners();
      print(error);
      rethrow;
    }
  }

}