// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:notedteamfrontend/models/invitation.dart';
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

  Future<Todo> createTodo(String token, int teamId, String title, String description, String urgency, DateTime? dueDate) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos');
    
    Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'urgency': urgency,
    };

    // HANYA tambahkan 'due_date' ke body jika tidak null.
    // Ini mencegah pengiriman {"due_date": null} saat membuat todo baru.
    if (dueDate != null) {
      body['due_date'] = dueDate.toUtc().toIso8601String();
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      print('Error Create Body: ${response.body}');
      throw Exception('Gagal membuat to-do');
    }
    return Todo.fromJson(json.decode(response.body)['data']);
  }

  Future<void> updateTodo({
    required String token,
    required int teamId,
    required int todoId,
    String? newStatus,
    String? newUrgency,
    DateTime? newDueDate,
    bool clearDueDate = false,
  }) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos/$todoId');

    Map<String, dynamic> body = {};

    if (newStatus != null) body['status'] = newStatus;
    if (newUrgency != null) body['urgency'] = newUrgency;

    // Logika eksplisit untuk tanggal
    if (clearDueDate) {
      body['due_date'] = null; // Kirim null untuk menghapus
    } else if (newDueDate != null) {
      body['due_date'] = newDueDate.toUtc().toIso8601String(); // Kirim tanggal baru dalam format UTC
    }

    // Jika tidak ada perubahan, jangan lakukan apa-apa
    if (body.isEmpty) return;

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      print('Error Update Body: ${response.body}');
      throw Exception('Gagal memperbarui to-do');
    }
  }


  Future<void> updateTodoDynamic(String token, int teamId, int todoId, Map<String, dynamic> changes) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/todos/$todoId');
    
    // Buat map baru untuk body JSON
    Map<String, dynamic> jsonBody = {};

    // Salin field yang bukan tanggal
    if (changes.containsKey('status')) jsonBody['status'] = changes['status'];
    if (changes.containsKey('urgency')) jsonBody['urgency'] = changes['urgency'];

    // Proses tanggal secara khusus
    if (changes.containsKey('due_date_object')) {
      final DateTime? date = changes['due_date_object'];
      jsonBody['due_date'] = date?.toUtc().toIso8601String(); // Konversi ke UTC string atau null
    }
    
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode(jsonBody),
    );

    if (response.statusCode != 200) {
      print('Error Body: ${response.body}');
      throw Exception('Gagal memperbarui to-do');
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

  Future<String> inviteUserToTeam(String token, int teamId, String email) async {
    final url = Uri.parse('$_baseUrl/api/teams/$teamId/invite');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'email': email}),
    );

    final responseData = json.decode(response.body);

    // Cek jika status code bukan 2xx (sukses)
    if (response.statusCode >= 400) {
      // Coba ambil pesan error, jika tidak ada, gunakan pesan default
      String errorMessage = responseData['error'] ?? 'An unknown error occurred.';
      throw Exception('Gagal mengundang pengguna: $errorMessage');
    }
    
    // Jika sukses (200 OK atau 201 Created), kembalikan pesan dari server
    return responseData['message'];
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
  Future<List<Invitation>> getMyInvitations(String token) async {
    final url = Uri.parse('$_baseUrl/api/invitations');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((inv) => Invitation.fromJson(inv)).toList();
    } else {
      throw Exception('Gagal mengambil undangan');
    }
  }
  Future<void> respondToInvitation(String token, int invitationId, bool accept) async {
    final url = Uri.parse('$_baseUrl/api/invitations/$invitationId/respond');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: json.encode({'accept': accept}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal merespons undangan');
    }
  }

}