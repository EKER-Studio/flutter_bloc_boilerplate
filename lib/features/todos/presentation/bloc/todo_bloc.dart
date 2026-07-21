import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
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

  /// FIFO queue of recently deleted todos. Using a queue instead of a single
  /// nullable field prevents rapid-fire deletions (e.g. consecutive swipe-to-
  /// dismiss gestures) from overwriting the pending undo reference before the
  /// user acts on it.
  final Queue<Todo> _undoQueue = Queue<Todo>();

  void _onWatchTodos(WatchTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoadInProgress());
    _todosSubscription?.cancel();
    _todosSubscription = _repository.watchAll().listen(
      (todos) => add(TodosUpdated(todos)),
      onError: (Object error) => add(TodosUpdated(<Todo>[])),
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
    try {
      final currentState = state;
      if (currentState is TodoLoadSuccess) {
        final todo = currentState.todos
            .where((t) => t.id == event.id)
            .firstOrNull;
        if (todo != null) {
          _undoQueue.addLast(todo);
        }
      }
      final result = await _repository.delete(id: event.id);
      if (result.$2 != null) {
        if (_undoQueue.isNotEmpty) _undoQueue.removeLast();
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      if (_undoQueue.isNotEmpty) _undoQueue.removeLast();
      emit(TodoLoadFailure(DatabaseFailure('Delete failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoRestored(
    TodoRestored event,
    Emitter<TodoState> emit,
  ) async {
    if (_undoQueue.isEmpty) return;
    try {
      final todo = _undoQueue.removeLast();
      final result = await _repository.restore(todo);
      if (result.$2 != null) {
        _undoQueue.addLast(todo);
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
