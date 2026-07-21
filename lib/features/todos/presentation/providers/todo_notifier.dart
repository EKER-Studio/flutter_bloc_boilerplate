import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';
import 'todo_repository_provider.dart';

part 'todo_notifier.g.dart';

/// Notifier for managing the list of todo items.
@riverpod
class TodoList extends _$TodoList {
  @override
  Stream<List<Todo>> build() {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.watchAll();
  }

  /// Adds a new todo item.
  Future<(bool success, Failure? failure)> addTodo(String title) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return (false, ValidationFailure('Title cannot be empty'));
    }
    return await ref.read(todoRepositoryProvider).add(title: trimmedTitle);
  }

  /// Toggles the completion status of a todo item.
  Future<(bool success, Failure? failure)> toggleTodo(int id) async {
    return await ref.read(todoRepositoryProvider).toggleCompleted(id: id);
  }

  /// Deletes a todo item.
  Future<(bool success, Failure? failure)> deleteTodo(int id) async {
    return await ref.read(todoRepositoryProvider).delete(id: id);
  }

  /// Restores a previously deleted todo item, used to implement "Undo".
  Future<(bool success, Failure? failure)> restoreTodo(Todo todo) async {
    return await ref.read(todoRepositoryProvider).restore(todo);
  }
}
