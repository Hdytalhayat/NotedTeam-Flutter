// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:notedteamfrontend/screens/todo_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil fetchAndSetTeams setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).fetchAndSetTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Teams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (ctx, teamProvider, child) {
          if (teamProvider.isLoading && teamProvider.teams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (teamProvider.teams.isEmpty) {
            return const Center(child: Text('Anda belum bergabung dengan tim manapun.'));
          }
          return ListView.builder(
            itemCount: teamProvider.teams.length,
            itemBuilder: (ctx, i) {
              final team = teamProvider.teams[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(team.name),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => TodoScreen(
                        teamId: team.id,
                        teamName: team.name,
                      ),
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}