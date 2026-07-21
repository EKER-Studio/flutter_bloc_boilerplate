import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../shared/format.dart';

/// Screen displaying the details of a single todo item.
class TodoDetailScreen extends StatelessWidget {
  const TodoDetailScreen({super.key, required this.todoId});

  final int todoId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (previous, current) =>
          current is TodoLoadSuccess &&
          current.todos.where((t) => t.id == todoId).isEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo was deleted')),
        );
        Navigator.of(context).pop();
      },
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          Todo? todo;
          if (state is TodoLoadSuccess) {
            todo = state.todos.where((t) => t.id == todoId).firstOrNull;
          }

          if (todo == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Task Details')),
              body: const Center(child: Text('Todo not found')),
            );
          }

          return _buildDetails(context, todo);
        },
      ),
    );
  }

  Scaffold _buildDetails(BuildContext context, Todo todo) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<TodoBloc>().add(TodoDeleted(todo.id));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Completed'),
              value: todo.isCompleted,
              onChanged: (_) {
                context.read<TodoBloc>().add(TodoToggled(todo.id));
              },
            ),
            const Divider(),
            Text(
              'Created',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(formatTodoDate(todo.createdAt)),
          ],
        ),
      ),
    );
  }
}


