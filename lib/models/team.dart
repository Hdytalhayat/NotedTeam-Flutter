// lib/models/team.dart
class Team {
  final int id;
  final String name;
  final int ownerId;

  Team({
    required this.id,
    required this.name,
    required this.ownerId,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      ownerId: json['owner_id'],
    );
  }
}