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
    on<WatchTodos>(_onWatchTodos);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoWatchFailed>(_onTodoWatchFailed);
    on<TodosUpdated>(_onTodosUpdated);
  }

  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _todosSubscription;

  void _onWatchTodos(WatchTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoadInProgress());
    _todosSubscription?.cancel();
    _todosSubscription = _repository.watchAll().listen(
      (todos) => add(TodosUpdated(todos)),
      onError: (Object error) {
        final failure = error is Failure
            ? error
            : DatabaseFailure('Watch stream error: ${error.toString()}');
        add(TodoWatchFailed(failure));
      },
    );
  }

  void _onTodoWatchFailed(TodoWatchFailed event, Emitter<TodoState> emit) {
    emit(TodoLoadFailure(event.failure));
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodoState> emit) {
    emit(TodoLoadSuccess(todos: event.todos));
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
      final result = await _repository.delete(id: event.todo.id);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Delete failed: ${e.toString()}')));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
