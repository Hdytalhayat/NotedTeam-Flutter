// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/todo.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.1.3:8080';

  Future<List<Team>> getMyTeams(String token) async {
    final url = Uri.parse('$_baseUrl/api/teams');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Header otentikasi
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((teamJson) => Team.fromJson(teamJson)).toList();
    } else {
      throw Exception('Gagal mengambil data tim');
    }
  }

  Future<List<Todo>> getTeamTodos(String token, int teamId) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((todoJson) => Todo.fromJson(todoJson)).toList();
    } else {
      throw Exception('Gagal mengambil data to-do');
    }
  }
  Future<Team> createTeam(String token, String name) async {
    final url = Uri.parse('$_baseUrl/api/teams');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 201) {
      return Team.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Gagal membuat tim');
    }
  }

  Future<Todo> createTodo(String token, int teamId, String title, String description) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body)['data']);
    } else {
      throw Exception('Gagal membuat to-do');
    }
  }

  Future<void> updateTodoStatus(String token, int teamId, int todoId, String newStatus) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos/$todoId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status to-do');
    }
  }

  Future<void> deleteTodo(String token, int teamId, int todoId) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos/$todoId');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus to-do');
    }
  }

  Future<void> inviteUserToTeam(String token, int teamId, String email) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/invite');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      // Ambil pesan error spesifik dari backend
      final errorData = json.decode(response.body);
      throw Exception('Gagal mengundang pengguna: ${errorData['error']}');
    }
  }
  Future<void> updateTeamName(String token, int teamId, String newName) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': newName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui nama tim');
    }
  }

  Future<void> deleteTeam(String token, int teamId) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus tim');
    }
  }

}