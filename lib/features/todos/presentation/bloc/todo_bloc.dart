import 'dart:async';

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
    on<WatchTodos>(_onWatchTodos);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoRestored>(_onTodoRestored);
  }

  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _todosSubscription;
  Todo? _lastDeletedTodo;

  void _onWatchTodos(WatchTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoadInProgress());
    _todosSubscription?.cancel();
    _todosSubscription = _repository.watchAll().listen(
      (todos) => emit(
        TodoLoadSuccess(
          todos: todos,
          lastDeletedTodo: _lastDeletedTodo,
        ),
      ),
      onError: (Object error) =>
          emit(TodoLoadFailure(DatabaseFailure(error.toString()))),
    );
  }

  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    final result = await _repository.add(title: event.title);
    if (result.$2 != null) {
      emit(TodoLoadFailure(result.$2!));
    }
  }

  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    final result = await _repository.toggleCompleted(id: event.id);
    if (result.$2 != null) {
      emit(TodoLoadFailure(result.$2!));
    }
  }

  Future<void> _onTodoDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadSuccess) {
      _lastDeletedTodo = currentState.todos
          .where((t) => t.id == event.id)
          .firstOrNull;
    }
    final result = await _repository.delete(id: event.id);
    if (result.$2 != null) {
      _lastDeletedTodo = null;
      emit(TodoLoadFailure(result.$2!));
    }
  }

  Future<void> _onTodoRestored(
    TodoRestored event,
    Emitter<TodoState> emit,
  ) async {
    if (_lastDeletedTodo == null) return;
    final result = await _repository.restore(_lastDeletedTodo!);
    if (result.$2 != null) {
      emit(TodoLoadFailure(result.$2!));
    } else {
      _lastDeletedTodo = null;
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
