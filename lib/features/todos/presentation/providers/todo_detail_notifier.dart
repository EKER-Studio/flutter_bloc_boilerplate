import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/todo.dart';
import 'todo_repository_provider.dart';

part 'todo_detail_notifier.g.dart';

/// Notifier for managing the state of a single todo item.
@riverpod
class TodoDetail extends _$TodoDetail {
  @override
  Stream<Todo?> build(int id) {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.watchById(id);
  }
}
