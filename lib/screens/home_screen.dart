// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:notedteamfrontend/models/team.dart';
import 'package:notedteamfrontend/screens/settings_screen.dart';
import 'package:notedteamfrontend/screens/todo_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import 'invitations_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/responsive_layout.dart';
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
// Buat metode refresh agar kode lebih bersih
  Future<void> _refreshTeams(BuildContext context) async {
    // Cukup panggil metode fetch dari provider
    await Provider.of<TeamProvider>(context, listen: false).fetchAndSetTeams();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myTeams),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline), // Ikon untuk undangan
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const InvitationsScreen()),
              );
            },
            tooltip: 'My Invitations',
          ),
          IconButton(
            icon: const Icon(Icons.settings), // Ikon untuk pengaturan
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
              );
            },
            tooltip: AppLocalizations.of(context)!.settings,
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          )
        ],
      ),
      body: ResponsiveLayout( 

        child: Consumer<TeamProvider>(
        
        builder: (ctx, teamProvider, child) {
          if (teamProvider.isLoading && teamProvider.teams.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (teamProvider.teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_copy_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTeamsJoined,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.createTeamToGetStarted,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshTeams(context),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    onLongPress: () { // Tambahkan onLongPress
                      _showTeamOptionsDialog(context, team);
                    },
                  ),
                );
              },
            )
          );
        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTeamDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Create Team',
      ),

    );
  }
  void _showCreateTeamDialog(BuildContext context) {
    final teamNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New Team'),
        content: TextField(
          controller: teamNameController,
          decoration: const InputDecoration(labelText: 'Team Name'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Create'),
            onPressed: () {
              if (teamNameController.text.isNotEmpty) {
                Provider.of<TeamProvider>(context, listen: false)
                    .createTeam(teamNameController.text);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }
// Tambahkan metode ini di dalam class _HomeScreenState
  void _showTeamOptionsDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(team.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename Team'),
              onTap: () {
                Navigator.of(ctx).pop(); // Tutup dialog opsi
                _showRenameTeamDialog(context, team);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Team', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop(); // Tutup dialog opsi
                _showDeleteConfirmDialog(context, team);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tambahkan metode untuk rename
  void _showRenameTeamDialog(BuildContext context, Team team) {
    final teamNameController = TextEditingController(text: team.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Team'),
        content: TextField(
          controller: teamNameController,
          decoration: const InputDecoration(labelText: 'New Team Name'),
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              if (teamNameController.text.isNotEmpty) {
                Provider.of<TeamProvider>(context, listen: false)
                    .updateTeamName(team.id, teamNameController.text);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  // Tambahkan metode untuk konfirmasi delete
  void _showDeleteConfirmDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to permanently delete "${team.name}" and all of its todos? This action cannot be undone.'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
            onPressed: () {
              Provider.of<TeamProvider>(context, listen: false).deleteTeam(team.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
