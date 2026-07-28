import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';

import '../../domain/entities/todo.dart';

/// Events that can be dispatched to [TodoBloc].
sealed class TodoEvent {
  const TodoEvent();
}

/// Requests the initial load of all todos.
class WatchTodos extends TodoEvent {
  /// Creates a [WatchTodos] event.
  const WatchTodos();
}

/// Adds a new todo with the given title.
class TodoAdded extends TodoEvent {
  /// Creates a [TodoAdded] event with the given [title].
  const TodoAdded(this.title);

  /// The title of the new todo.
  final String title;
}

/// Toggles the completed state of a todo identified by [id].
class TodoToggled extends TodoEvent {
  /// Creates a [TodoToggled] event for the todo with [id].
  const TodoToggled(this.id);

  /// The id of the todo to toggle.
  final int id;
}

/// Deletes a todo.
class TodoDeleted extends TodoEvent {
  /// Creates a [TodoDeleted] event for the given [todo].
  const TodoDeleted(this.todo);

  /// The todo to delete.
  final Todo todo;
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports an updated todo list. Not intended to be dispatched from the UI.
class TodosUpdated extends TodoEvent {
  /// Creates a [TodosUpdated] event with the given [todos].
  const TodosUpdated(this.todos);

  /// The complete current list of todos.
  final List<Todo> todos;
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports an error. Not intended to be dispatched from the UI.
class TodoWatchFailed extends TodoEvent {
  /// Creates a [TodoWatchFailed] event with the given [failure].
  const TodoWatchFailed(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
