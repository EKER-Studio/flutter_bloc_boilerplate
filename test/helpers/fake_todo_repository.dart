import 'dart:async';

import 'package:flutter_riverpod_boilerplate/core/errors/failure.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/repositories/todo_repository.dart';

/// In-memory implementation of [TodoRepository] for use in tests.
///
/// Emits reactive updates through an internal [StreamController], making it
/// suitable for both widget and unit tests. An optional [clock] parameter
/// allows injecting a deterministic time source for golden tests.
class FakeTodoRepository implements TodoRepository {
  /// Creates a [FakeTodoRepository].
  ///
  /// [initialTodos] pre-seeds the repository with the given list.
  /// [clock] overrides `DateTime.now()` used when creating new todos.
  FakeTodoRepository({
    List<Todo> initialTodos = const [],
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _todos = List.of(initialTodos);

  final DateTime Function() _clock;
  final List<Todo> _todos;
  final _streamController = StreamController<List<Todo>>.broadcast();

  void _emit() {
    _streamController.add(List.unmodifiable(_todos));
  }

  /// Releases the internal stream resources. Call in [tearDown].
  void dispose() {
    _streamController.close();
  }

  @override
  Stream<List<Todo>> watchAll() async* {
    yield List.unmodifiable(_todos);
    yield* _streamController.stream;
  }

  @override
  Stream<Todo?> watchById(int id) async* {
    yield _todos
        .where((todo) => todo.id == id)
        .cast<Todo?>()
        .firstWhere((_) => true, orElse: () => null);
    yield* _streamController.stream.map(
      (todos) => todos
          .where((todo) => todo.id == id)
          .cast<Todo?>()
          .firstWhere((_) => true, orElse: () => null),
    );
  }

  @override
  Future<List<Todo>> getAll() async {
    return List.unmodifiable(_todos);
  }

  @override
  Future<(bool success, Failure? failure)> add({required String title}) async {
    _todos.insert(
      0,
      Todo(
        id: _todos.length + 1,
        title: title,
        isCompleted: false,
        createdAt: _clock(),
      ),
    );
    _emit();
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> toggleCompleted({
    required int id,
  }) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return (false, NotFoundFailure('Todo with id $id not found'));
    }

    final todo = _todos[index];
    _todos[index] = todo.copyWith(isCompleted: !todo.isCompleted);
    _emit();
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> delete({required int id}) async {
    _todos.removeWhere((todo) => todo.id == id);
    _emit();
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> restore(Todo todo) async {
    _todos.insert(0, todo);
    _emit();
    return (true, null);
  }
}
