// lib/models/todo.dart
class Todo {
  final int id;
  final String title;
  final String description;
  final String status;
  final String urgency;
  final int teamId;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.urgency,
    required this.teamId,
    this.dueDate, 
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
    );
  }
}