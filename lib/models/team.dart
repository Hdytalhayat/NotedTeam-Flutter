// lib/models/team.dart
import 'package:notedteamfrontend/models/user.dart';

class Team {
  final int id;
  final String name;
  final int ownerId;
  final List<User> members; 
  Team({
    required this.id,
    required this.name,
    required this.ownerId,
    this.members = const [],
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    // Ambil daftar member jika ada
    var memberList = <User>[];
    if (json['members'] != null) {
      memberList = (json['members'] as List)
          .map((memberJson) => User.fromJson(memberJson))
          .toList();
    }

    return Team(
      id: json['id'],
      name: json['name'],
      ownerId: json['owner_id'],
      members: memberList, // Masukkan daftar member
    );
  }

}