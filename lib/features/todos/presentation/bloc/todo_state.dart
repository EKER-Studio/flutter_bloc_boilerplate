import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';

/// States emitted by [TodoBloc].
sealed class TodoState {
  const TodoState();
}

/// Initial state before [WatchTodos] is dispatched.
class TodoInitial extends TodoState {
  /// Creates a [TodoInitial] state.
  const TodoInitial();
}

/// Emitted while todos are being loaded.
class TodoLoadInProgress extends TodoState {
  /// Creates a [TodoLoadInProgress] state.
  const TodoLoadInProgress();
}

/// Emitted when todos were loaded or updated successfully.
class TodoLoadSuccess extends TodoState {
  /// Creates a [TodoLoadSuccess] state with the given [todos] and optional
  /// [lastDeletedTodo].
  const TodoLoadSuccess({required this.todos, this.lastDeletedTodo});

  /// The current list of todos.
  final List<Todo> todos;

  /// The most recently deleted todo available for undo, or null.
  final Todo? lastDeletedTodo;
}

/// Emitted when a todo operation failed.
class TodoLoadFailure extends TodoState {
  /// Creates a [TodoLoadFailure] state with the given [failure].
  const TodoLoadFailure(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
