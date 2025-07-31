// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/team_provider.dart';
import 'package:intl/intl.dart';

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
      teamProvider.fetchCurrentTeamDetails(widget.teamId);
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
            icon: const Icon(Icons.people_outline), // Ikon untuk member
            onPressed: () => _showMembersDialog(context),
            tooltip: 'Team Members',
          ),

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
                        subtitle: Column( // Bungkus dengan Column
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(todo.description),
                            if (todo.dueDate != null) // Tampilkan hanya jika ada
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Due: ${DateFormat.yMMMd().format(todo.dueDate!)}', // Format tanggal
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: todo.dueDate!.isBefore(DateTime.now()) && todo.status != 'completed' 
                                        ? Colors.red 
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  _buildAuditString(todo), // Gunakan helper untuk membuat string
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                                ),
                              ),

                          ],
                        ),

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
    DateTime? selectedDate;
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
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(selectedDate == null
                        ? 'No Due Date'
                        : 'Due: ${DateFormat.yMMMd().format(selectedDate!)}'),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
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
                        selectedUrgency,
                        selectedDate, // Kirim DateTime?
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
    DateTime? selectedDate = todo.dueDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit To-do'),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(selectedDate == null
                          ? 'Set Due Date'
                          : 'Due: ${DateFormat.yMMMd().format(selectedDate!)}'),
                      // trailing: selectedDate != null
                      //     ? IconButton(
                      //         icon: const Icon(Icons.clear),
                      //         onPressed: () => setState(() => selectedDate = null),
                      //       )
                      //     : null,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                ElevatedButton(
                  child: const Text('Save Changes'),
                  onPressed: () {
                    // Panggil provider dengan logika yang jelas
                    Provider.of<TeamProvider>(context, listen: false).updateTodo(
                      teamId: widget.teamId,
                      todoId: todo.id,
                      // Kirim HANYA jika nilainya berubah
                      newStatus: todo.status != selectedStatus ? selectedStatus : null,
                      newUrgency: todo.urgency != selectedUrgency ? selectedUrgency : null,
                      // Logika tanggal yang jelas
                      newDueDate: todo.dueDate != selectedDate && selectedDate != null ? selectedDate : null,
                      clearDueDate: todo.dueDate != null && selectedDate == null,
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

              final emailToInvite = emailController.text;
              Navigator.of(ctx).pop(); // Tutup dialog sebelum proses

              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengundang pengguna...')),
                );

                // Tangkap pesan sukses dari provider
                final successMessage = await teamProvider.inviteUserToTeam(
                  teamId,
                  emailToInvite,
                );
                
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(successMessage), // Tampilkan pesan dari server
                    backgroundColor: Colors.green,
                  ),
                );

              } catch (error) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString().replaceFirst("Exception: ", "")), // Hapus prefix "Exception: "
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
  void _showMembersDialog(BuildContext context) {
    // Ambil daftar member dari provider (listen: true agar update jika ada perubahan nanti)
    final members = Provider.of<TeamProvider>(context, listen: false).currentTeamMembers;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Team Members'),
        content: SizedBox(
          width: double.maxFinite,
          child: members.isEmpty
              ? const Text('No member data available.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (listCtx, i) {
                    final member = members[i];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(member.name),
                      subtitle: Text(member.email),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
  String _buildAuditString(Todo todo) {
    // Cek apakah to-do baru saja dibuat (creator sama dengan editor)
    if (todo.creator.id == todo.editor.id) {
      return 'Created by ${todo.creator.name}';
    }
    // Jika sudah pernah diedit
    return 'Edited by ${todo.editor.name} (Created by ${todo.creator.name})';
  }

}