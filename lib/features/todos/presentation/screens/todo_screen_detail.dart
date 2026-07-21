import 'package:flutter/material.dart';

/// Screen displaying the details of a single todo item.
class TodoDetailScreen extends StatelessWidget {
  /// Creates a [TodoDetailScreen].
  const TodoDetailScreen({super.key, required this.todoId});

  /// The ID of the todo item to display.
  final int todoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: const Center(
        child: Text('Todo detail view — BLoC integration pending'),
      ),
    );
  }
}
