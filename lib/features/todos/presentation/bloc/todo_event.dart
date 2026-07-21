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
