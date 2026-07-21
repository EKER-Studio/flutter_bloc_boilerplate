import '../../domain/entities/todo.dart';

sealed class TodoEvent {
  const TodoEvent();
}

class WatchTodos extends TodoEvent {
  const WatchTodos();
}

class TodoAdded extends TodoEvent {
  const TodoAdded(this.title);

  final String title;
}

class TodoToggled extends TodoEvent {
  const TodoToggled(this.id);

  final int id;
}

class TodoDeleted extends TodoEvent {
  const TodoDeleted(this.id);

  final int id;
}

class TodoRestored extends TodoEvent {
  const TodoRestored();
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports an updated todo list. Not intended to be dispatched from the UI.
class TodosUpdated extends TodoEvent {
  const TodosUpdated(this.todos);

  final List<Todo> todos;
}
