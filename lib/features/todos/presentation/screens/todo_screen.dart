import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/todo_notifier.dart';
import '../widgets/add_todo_fab.dart';
import '../widgets/todo_list_item.dart';

/// Screen displaying the list of todo items.
class TodoScreen extends ConsumerWidget {
  /// Creates a [TodoScreen].
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load tasks',
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
                  onPressed: () => ref.invalidate(todoListProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (todos) {
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first task using the button below',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: todos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoListItem(
                todo: todo,
                onToggle: () async {
                  final (success, failure) = await ref
                      .read(todoListProvider.notifier)
                      .toggleTodo(todo.id);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          failure?.userMessage ?? 'Failed to toggle task',
                        ),
                      ),
                    );
                  }
                },
                onDelete: () async {
                  final (success, failure) = await ref
                      .read(todoListProvider.notifier)
                      .deleteTodo(todo.id);
                  if (!context.mounted) return;
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          failure?.userMessage ?? 'Failed to delete task',
                        ),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${todo.title}"'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          final (restored, restoreFailure) = await ref
                              .read(todoListProvider.notifier)
                              .restoreTodo(todo);
                          if (!restored && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  restoreFailure?.userMessage ??
                                      'Failed to restore task',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: AddTodoFab(
        onAdd: (title) async {
          final (success, failure) = await ref
              .read(todoListProvider.notifier)
              .addTodo(title);
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure?.userMessage ?? 'Failed to add task'),
              ),
            );
          }
        },
      ),
    );
  }
}
