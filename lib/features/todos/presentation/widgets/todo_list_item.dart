import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/todo.dart';
import '../screens/todo_screen_detail.dart';

/// List item widget displaying a todo item.
class TodoListItem extends StatelessWidget {
  /// Creates a [TodoListItem].
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  /// The todo item to display.
  final Todo todo;

  /// Callback to execute when the todo is toggled.
  final VoidCallback onToggle;

  /// Callback to execute when the todo is deleted.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailScreen(todoId: todo.id),
            ),
          );
        },
        leading: Semantics(
          label: todo.isCompleted
              ? 'Mark "${todo.title}" as not done'
              : 'Mark "${todo.title}" as done',
          child: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: Text(
          _dateFormat.format(todo.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// Shared date format for displaying [Todo.createdAt], kept consistent with
/// [TodoDetailScreen].
final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
