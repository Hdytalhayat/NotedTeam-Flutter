// lib/models/invitation.dart
import 'team.dart';

class Invitation {
  final int id;
  final Team team; // Data tim yang mengundang

  Invitation({required this.id, required this.team});

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      team: Team.fromJson(json['team']),
    );
  }
}