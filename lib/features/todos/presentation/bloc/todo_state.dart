import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';

sealed class TodoState {
  const TodoState();
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoadInProgress extends TodoState {
  const TodoLoadInProgress();
}

class TodoLoadSuccess extends TodoState {
  const TodoLoadSuccess({required this.todos, this.lastDeletedTodo});

  final List<Todo> todos;
  final Todo? lastDeletedTodo;
}

class TodoLoadFailure extends TodoState {
  const TodoLoadFailure(this.failure);

  final Failure failure;
}
