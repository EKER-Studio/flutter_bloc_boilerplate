import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_todo_fab.dart';
import '../widgets/todo_list_item.dart';

/// Screen displaying the list of todo items.
///
/// ## Dependency scope contract
///
/// Both [TodoBloc] and [SettingsCubit] are provided at the `App` level via
/// `MultiBlocProvider` in `lib/app.dart`. This ensures that navigating to the
/// settings screen (which sits outside the todo navigation stack) does not lose
/// BLoC context — the widgets remain within the same provider ancestry. The
/// same contract applies to any BLoC whose lifespan should span the entire
/// application session rather than a single route.
class TodoScreen extends StatelessWidget {
  /// Creates a [TodoScreen].
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TodoBloc, TodoState>(
          listenWhen: (previous, current) =>
              current is TodoLoadFailure && previous is! TodoLoadFailure,
          listener: (context, state) {
            if (state is TodoLoadFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure.userMessage)),
              );
            }
          },
        ),
        BlocListener<TodoBloc, TodoState>(
          listenWhen: (previous, current) =>
              current is TodoLoadSuccess &&
              current.lastDeletedTodo != null &&
              (previous is! TodoLoadSuccess ||
                  previous.lastDeletedTodo != current.lastDeletedTodo),
          listener: (context, state) {
            if (state is TodoLoadSuccess && state.lastDeletedTodo != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Deleted "${state.lastDeletedTodo!.title}"'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () =>
                          context.read<TodoBloc>().add(const TodoRestored()),
                    ),
                  ),
                );
            }
          },
        ),
      ],
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          return switch (state) {
            TodoInitial() => const SizedBox.shrink(),
            TodoLoadInProgress() => _buildLoading(),
            TodoLoadSuccess(:final todos, :final lastDeletedTodo) => _buildList(
              context,
              todos,
              lastDeletedTodo,
            ),
            TodoLoadFailure(:final failure) => _buildError(
              context,
              failure.userMessage,
            ),
          };
        },
      ),
    );
  }

  Scaffold _buildLoading() {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildList(
    BuildContext context,
    List<Todo> todos,
    Todo? lastDeletedTodo,
  ) {
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
      body: todos.isEmpty
          ? const Center(child: Text('No todos yet'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoListItem(
                  todo: todo,
                  onToggle: () =>
                      context.read<TodoBloc>().add(TodoToggled(todo.id)),
                  onDelete: () =>
                      context.read<TodoBloc>().add(TodoDeleted(todo.id)),
                );
              },
            ),
      floatingActionButton: AddTodoFab(
        onAdd: (title) async {
          context.read<TodoBloc>().add(TodoAdded(title));
        },
      ),
    );
  }

  Scaffold _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $message'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<TodoBloc>().add(const WatchTodos()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
