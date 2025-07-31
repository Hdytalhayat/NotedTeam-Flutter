// lib/screens/invitations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../l10n/app_localizations.dart';
class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  _InvitationsScreenState createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false).fetchMyInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeamProvider>(context);
    final invitations = provider.invitations;

    return Scaffold(
      appBar: AppBar(title: const Text('My Invitations')),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMyInvitations(),
        child: invitations.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noPendingInvitations))
            : ListView.builder(
                itemCount: invitations.length,
                itemBuilder: (ctx, i) {
                  final inv = invitations[i];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('Invitation to join "${inv.team.name}"'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () {
                              provider.acceptInvitation(inv.id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              provider.declineInvitation(inv.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}