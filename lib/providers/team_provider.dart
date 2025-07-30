// lib/providers/team_provider.dart
import 'dart:async'; // Impor async
import 'dart:convert'; // Impor convert
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/websocket_service.dart';
import '../models/team.dart';
import '../models/todo.dart';

class TeamProvider with ChangeNotifier {
  // ... (kode yang ada) ...
  // Tambahkan konstruktor ini
  TeamProvider(); 
  // ...

  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService(); // Instance service
  StreamSubscription? _socketSubscription; // Untuk mengelola listener
  
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
  void connectToTeamChannel(int teamId) {
    if (_authToken == null) return;
    _webSocketService.connect(teamId, _authToken!);

    // Batalkan listener lama jika ada
    _socketSubscription?.cancel();
    
    // Mulai mendengarkan pesan baru dari WebSocket
    _socketSubscription = _webSocketService.messages.listen((message) {
      _handleSocketMessage(message);
    });
  }
  void disconnectFromTeamChannel() {
    _webSocketService.disconnect();
    _socketSubscription?.cancel();
  }
  void _handleSocketMessage(String message) {
    final decodedMessage = json.decode(message);
    final event = decodedMessage['event'];
    final data = decodedMessage['data'];

    switch (event) {
      case 'todo_created':
        final newTodo = Todo.fromJson(data);
        _currentTodos.insert(0, newTodo);
        break;
      case 'todo_updated':
        final updatedTodo = Todo.fromJson(data);
        final index = _currentTodos.indexWhere((t) => t.id == updatedTodo.id);
        if (index != -1) {
          _currentTodos[index] = updatedTodo;
        }
        break;
      case 'todo_deleted':
        final int todoId = data['id'];
        _currentTodos.removeWhere((t) => t.id == todoId);
        break;
    }
    // Beri tahu UI untuk membangun ulang!
    notifyListeners();
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

  Future<void> createTodo(int teamId, String title, String description, String urgency) async {
    if (_authToken == null) return;
    try {
      await _apiService.createTodo(_authToken!, teamId, title, description, urgency);
    } catch (error) { rethrow; }
  }


  Future<void> updateTodo(int teamId, int todoId, {String? newStatus, String? newUrgency}) async {
    if (_authToken == null) return;
    try {
      await _apiService.updateTodoStatus(_authToken!, teamId, todoId, newStatus: newStatus, newUrgency: newUrgency);
    } catch (error) { rethrow; }
  }



  Future<void> deleteTodo(int teamId, int todoId) async {
    if (_authToken == null) return;
    try {
      await _apiService.deleteTodo(_authToken!, teamId, todoId);
    } catch (error) {
      print(error);
      rethrow;
    }
  }
  // Penting: Pastikan provider di-dispose dengan benar
  @override
  void dispose() {
    disconnectFromTeamChannel();
    super.dispose();
  }
  Future<void> inviteUserToTeam(int teamId, String email) async {
    if (_authToken == null) return;
    try {
      await _apiService.inviteUserToTeam(_authToken!, teamId, email);
    } catch (error) {
      // Lemparkan lagi error agar UI bisa menangkap dan menampilkannya
      rethrow;
    }
  }
  Future<void> updateTeamName(int teamId, String newName) async {
    if (_authToken == null) return;
    try {
      await _apiService.updateTeamName(_authToken!, teamId, newName);
      // Perbarui state lokal
      final teamIndex = _teams.indexWhere((team) => team.id == teamId);
      if (teamIndex != -1) {
        _teams[teamIndex] = Team(
          id: teamId,
          name: newName,
          ownerId: _teams[teamIndex].ownerId, // Owner ID tidak berubah
        );
        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteTeam(int teamId) async {
    if (_authToken == null) return;
    try {
      await _apiService.deleteTeam(_authToken!, teamId);
      // Hapus dari state lokal
      _teams.removeWhere((team) => team.id == teamId);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

}