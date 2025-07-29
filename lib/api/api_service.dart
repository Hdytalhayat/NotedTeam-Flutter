// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team.dart';
import '../models/todo.dart';

class ApiService {
  final String _baseUrl = 'http://192.168.1.2:8080';

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
}