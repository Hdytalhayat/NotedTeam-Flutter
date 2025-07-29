// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeamProvider>(context, listen: false)
          .fetchAndSetTodos(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final todos = Provider.of<TeamProvider>(context).currentTodos;
    final isLoading = Provider.of<TeamProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
      ),
      body: isLoading && todos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (ctx, i) {
                final todo = todos[i];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Text(todo.status),
                );
              },
            ),
    );
  }
}