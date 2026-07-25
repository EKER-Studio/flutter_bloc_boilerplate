import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

/// BLoC managing the todo list state.
@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  /// Creates a bloc backed by the given repository.
  TodoBloc(this._repository) : super(const TodoInitial()) {
    on<TodosUpdated>(_onTodosUpdated);
    on<WatchTodos>(_onWatchTodos);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoRestored>(_onTodoRestored);
  }

  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _todosSubscription;

  /// List of recently deleted todos used as an undo stack. Using a list
  /// instead of a single nullable field prevents rapid-fire deletions (e.g.
  /// consecutive swipe-to-dismiss gestures) from overwriting the pending undo
  /// reference before the user acts on it.
  final List<Todo> _undoQueue = [];

  void _onWatchTodos(WatchTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoadInProgress());
    _todosSubscription?.cancel();
    _todosSubscription = _repository.watchAll().listen(
      (todos) => add(TodosUpdated(todos)),
      onError: (Object error) {
        final failure = error is Failure
            ? error
            : DatabaseFailure('Watch stream error: ${error.toString()}');
        emit(TodoLoadFailure(failure));
      },
    );
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodoState> emit) {
    emit(
      TodoLoadSuccess(
        todos: event.todos,
        lastDeletedTodo: _undoQueue.isEmpty ? null : _undoQueue.last,
      ),
    );
  }

  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    try {
      final result = await _repository.add(title: event.title);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Add failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final result = await _repository.toggleCompleted(id: event.id);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Toggle failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) async {
    _undoQueue.add(event.todo);
    try {
      final result = await _repository.delete(id: event.todo.id);
      if (result.$2 != null) {
        // Deletion failed — remove the specific item we just added from the
        // queue tail before emitting the error so the undo snackbar never
        // references a stale item.
        if (_undoQueue.isNotEmpty && _undoQueue.last.id == event.todo.id) {
          _undoQueue.removeLast();
        }
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      // An exception (e.g. IsarError) may have left the queue in an
      // inconsistent state. Remove only the item matching this deletion so
      // other pending undo items remain intact.
      _undoQueue.removeWhere((todo) => todo.id == event.todo.id);
      emit(TodoLoadFailure(DatabaseFailure('Delete failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoRestored(
    TodoRestored event,
    Emitter<TodoState> emit,
  ) async {
    // Look up the specific todo by id rather than blindly restoring .last.
    // This guards against restoration mismatches when concurrent deletions
    // shift the queue or when the user triggers undo on a stale snackbar.
    final targetIndex = _undoQueue.indexWhere(
      (todo) => todo.id == event.todoId,
    );
    if (targetIndex == -1) return;

    final todo = _undoQueue[targetIndex];
    try {
      final result = await _repository.restore(todo);
      if (result.$1) {
        _undoQueue.removeAt(targetIndex);
      } else {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Restore failed: ${e.toString()}')));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
