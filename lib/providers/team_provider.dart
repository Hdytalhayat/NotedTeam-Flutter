// lib/providers/team_provider.dart
import 'dart:async'; // Impor async
import 'dart:convert'; // Impor convert
import 'package:flutter/material.dart';
import 'package:notedteamfrontend/models/invitation.dart';
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

  List<Invitation> _invitations = [];
  List<Invitation> get invitations => _invitations;
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

// Perbaiki createTodo agar cocok dengan ApiService
  Future<void> createTodo(
      int teamId, String title, String description, String urgency, DateTime? dueDate) async {
    if (_authToken == null) return;
    try {
      await _apiService.createTodo(_authToken!, teamId, title, description, urgency, dueDate);
    } catch (error) { rethrow; }
  }

  // Ganti updateTodoDynamic dengan updateTodo yang baru
  Future<void> updateTodo({
    required int teamId,
    required int todoId,
    String? newStatus,
    String? newUrgency,
    DateTime? newDueDate,
    bool clearDueDate = false,
  }) async {
    if (_authToken == null) return;
    try {
      await _apiService.updateTodo(
        token: _authToken!,
        teamId: teamId,
        todoId: todoId,
        newStatus: newStatus,
        newUrgency: newUrgency,
        newDueDate: newDueDate,
        clearDueDate: clearDueDate,
      );
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
  Future<String> inviteUserToTeam(int teamId, String email) async {
    if (_authToken == null) throw Exception("Not authenticated");
    try {
      // Kembalikan string pesan sukses
      return await _apiService.inviteUserToTeam(_authToken!, teamId, email);
    } catch (error) {
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
  Future<void> fetchMyInvitations() async {
    if (_authToken == null) return;
    try {
      _invitations = await _apiService.getMyInvitations(_authToken!);
      notifyListeners();
    } catch (error) { rethrow; }
  }

  Future<void> acceptInvitation(int invitationId) async {
    if (_authToken == null) return;
    try {
      await _apiService.respondToInvitation(_authToken!, invitationId, true);
      // Hapus dari daftar lokal dan segarkan daftar tim
      _invitations.removeWhere((inv) => inv.id == invitationId);
      await fetchAndSetTeams(); // <-- Penting! Refresh daftar tim
      notifyListeners();
    } catch (error) { rethrow; }
  }

  Future<void> declineInvitation(int invitationId) async {
    if (_authToken == null) return;
    try {
      await _apiService.respondToInvitation(_authToken!, invitationId, false);
      _invitations.removeWhere((inv) => inv.id == invitationId);
      notifyListeners();
    } catch (error) { rethrow; }
  }

}