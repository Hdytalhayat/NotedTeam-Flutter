// lib/models/todo.dart
import 'package:notedteamfrontend/models/user.dart';

class Todo {
  final int id;
  final String title;
  final String description;
  final String status;
  final String urgency;
  final int teamId;
  final DateTime? dueDate;
  final User creator; // Ganti dari ID menjadi objek User
  final User editor; // Tambahkan objek User

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.urgency,
    required this.teamId,
    this.dueDate, 
    required this.creator,
    required this.editor,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '', // Handle jika null
      status: json['status'],
      urgency: json['urgency'],
      teamId: json['team_id'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      creator: json['creator'] != null 
        ? User.fromJson(json['creator']) 
        : User(id: 0, name: 'Unknown', email: ''),
      editor: json['editor'] != null 
        ? User.fromJson(json['editor'])
        : User(id: 0, name: 'Unknown', email: ''),
      );
  }
}