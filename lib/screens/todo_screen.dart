// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/team_provider.dart';

class TodoScreen extends StatefulWidget {
  final int teamId;
  final String teamName;

  const TodoScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Ambil data awal melalui HTTP
      teamProvider.fetchAndSetTodos(widget.teamId);
      
      // 2. Buka koneksi WebSocket untuk real-time update
      teamProvider.connectToTeamChannel(widget.teamId);
    });
  }
  @override
  void dispose() {
    // 3. Putuskan koneksi WebSocket saat layar ditutup
    // Ini sangat penting untuk mencegah memory leak!
    WidgetsBinding.instance.addPostFrameCallback((_) {
       Provider.of<TeamProvider>(context, listen: false).disconnectFromTeamChannel();
    });
    super.dispose();
  }
  Future<void> _refreshTodos(BuildContext context) async {
    await Provider.of<TeamProvider>(context, listen: false)
        .fetchAndSetTodos(widget.teamId);
  }
  @override
  Widget build(BuildContext context) {
    // Pindahkan provider call ke sini agar lebih mudah dibaca
    final teamProvider = Provider.of<TeamProvider>(context);
    final todos = teamProvider.currentTodos;
    final isLoading = teamProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        actions: [ // Tambahkan actions
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showInviteDialog(context, widget.teamId),
            tooltip: 'Invite User',
          ),
        ],

      ),
      body: isLoading && todos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshTodos(context),
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (ctx, i) {
                  final todo = todos[i];
                  return Dismissible( // Widget untuk swipe-to-delete
                    key: ValueKey(todo.id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      teamProvider.deleteTodo(widget.teamId, todo.id);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                      child: ListTile(
                        leading: _getUrgencyIcon(todo.urgency),
                        title: Text(todo.title),
                        subtitle: Text(todo.description),
                        trailing: Chip(
                          label: Text(
                            todo.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getStatusColor(todo.status),
                        ),
                        onTap: () => _showEditTodoDialog(context, todo),
                      ),
                    ),
                  );
                },
              )
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTodoDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add To-do',
      ),
    );
  }
  // Tambahkan metode ini di dalam class _TodoScreenState
  void _showCreateTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedUrgency = 'low'; // Default urgency

    showDialog(
      context: context,
      builder: (ctx) {
        // Bungkus dengan StatefulBuilder agar dropdown bisa di-update
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New To-do'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                  TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedUrgency,
                    decoration: const InputDecoration(labelText: 'Urgency'),
                    items: ['low', 'medium', 'high'].map((urgency) {
                      return DropdownMenuItem(
                        value: urgency,
                        child: Text(urgency.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() { // Update state di dalam dialog
                          selectedUrgency = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      Provider.of<TeamProvider>(context, listen: false).createTodo(
                        widget.teamId,
                        titleController.text,
                        descriptionController.text,
                        selectedUrgency, // Kirim urgensi yang dipilih
                      );
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Tambahkan metode ini juga
  void _showEditTodoDialog(BuildContext context, Todo todo) {
    String selectedStatus = todo.status;
    String selectedUrgency = todo.urgency;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit To-do'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['pending', 'working', 'completed'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedStatus = value!),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedUrgency,
                    decoration: const InputDecoration(labelText: 'Urgency'),
                    items: ['low', 'medium', 'high'].map((urgency) {
                      return DropdownMenuItem(value: urgency, child: Text(urgency.toUpperCase()));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedUrgency = value!),
                  ),
                ],
              ),
              actions: [
                TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: const Text('Save Changes'),
                  onPressed: () {
                    Provider.of<TeamProvider>(context, listen: false).updateTodo(
                      widget.teamId,
                      todo.id,
                      newStatus: selectedStatus,
                      newUrgency: selectedUrgency,
                    );
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInviteDialog(BuildContext context, int teamId) {
    final emailController = TextEditingController();
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite User to Team'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'User Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Invite'),
            onPressed: () async {
              if (emailController.text.isEmpty) return;

              // Tutup dialog
              Navigator.of(ctx).pop();

              try {
                // Tampilkan snackbar loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengundang pengguna...')),
                );

                await teamProvider.inviteUserToTeam(
                  teamId,
                  emailController.text,
                );
                
                // Hapus snackbar loading dan tampilkan snackbar sukses
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengguna berhasil diundang!'),
                    backgroundColor: Colors.green,
                  ),
                );

              } catch (error) {
                // Hapus snackbar loading dan tampilkan snackbar error
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  Icon _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'high':
        return const Icon(Icons.arrow_upward, color: Colors.red);
      case 'medium':
        return const Icon(Icons.remove, color: Colors.orange);
      case 'low':
      default:
        return const Icon(Icons.arrow_downward, color: Colors.green);
    }
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'working':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

}