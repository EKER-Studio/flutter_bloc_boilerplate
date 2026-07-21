import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/failure.dart';
import '../providers/todo_detail_notifier.dart';

/// Screen displaying the details of a single todo item.
class TodoDetailScreen extends ConsumerWidget {
  /// Creates a [TodoDetailScreen].
  const TodoDetailScreen({super.key, required this.todoId});

  /// The ID of the todo item to display.
  final int todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoAsync = ref.watch(todoDetailProvider(todoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: todoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'An error occurred',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error is Failure ? error.userMessage : error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(todoDetailProvider(todoId)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (todo) {
          if (todo == null) {
            return Center(
              child: Text(
                'Task not found.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                todo.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                context,
                icon: todo.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                iconColor: todo.isCompleted ? Colors.green : Colors.grey,
                label: 'Status',
                value: todo.isCompleted ? 'Completed' : 'In progress',
              ),
              const Divider(height: 32),
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                label: 'Created at',
                value: dateFormat.format(todo.createdAt),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: iconColor ?? Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
