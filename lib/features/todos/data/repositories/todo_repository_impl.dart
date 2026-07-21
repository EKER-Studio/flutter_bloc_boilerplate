import 'dart:async';
import 'dart:developer';

import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../mappers/todo_mapper.dart';
import '../models/todo_model.dart';

/// Default implementation of [TodoRepository] backed by Isar.
@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  /// Creates a new [TodoRepositoryImpl] with the given Isar instance.
  TodoRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Stream<List<Todo>> watchAll() {
    return _watchWithReconnect(
      () => _isar.todoModels
          .where()
          .sortByCreatedAtDesc()
          .watch(fireImmediately: true)
          .map((models) => models.map((m) => m.toEntity()).toList()),
      'watchAll',
    );
  }

  @override
  Stream<Todo?> watchById(int id) {
    return _watchWithReconnect(
      () => _isar.todoModels
          .watchObject(id, fireImmediately: true)
          .map((model) => model?.toEntity()),
      'watchById($id)',
    );
  }

  /// Wraps an Isar watch stream in an auto-reconnecting loop so transient
  /// database errors don't permanently terminate the subscription. The
  /// calling BLoC can rely on the stream staying alive.
  Stream<T> _watchWithReconnect<T>(
    Stream<T> Function() createStream,
    String label,
  ) async* {
    while (true) {
      try {
        yield* createStream();
        return;
      } catch (e, s) {
        log(
          'Isar watch stream "$label" error, reconnecting in 1s',
          error: e,
          stackTrace: s,
        );
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  Future<List<Todo>> getAll() async {
    try {
      final models = await _isar.todoModels
          .where()
          .sortByCreatedAtDesc()
          .findAll();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw DatabaseFailure('Failed to load todos: ${e.toString()}');
    }
  }

  @override
  Future<(bool success, Failure? failure)> add({required String title}) async {
    try {
      final model = TodoModel()
        ..title = title.trim()
        ..createdAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.todoModels.put(model);
      });
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<(bool success, Failure? failure)> toggleCompleted({
    required int id,
  }) async {
    try {
      var found = false;
      await _isar.writeTxn(() async {
        final model = await _isar.todoModels.get(id);
        if (model == null) {
          return;
        }

        found = true;
        model.isCompleted = !model.isCompleted;
        await _isar.todoModels.put(model);
      });
      if (!found) {
        return (false, NotFoundFailure('Todo not found'));
      }
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<(bool success, Failure? failure)> delete({required int id}) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.todoModels.delete(id);
      });
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<(bool success, Failure? failure)> restore(Todo todo) async {
    try {
      final model = TodoModel()
        ..id = todo.id
        ..title = todo.title
        ..isCompleted = todo.isCompleted
        ..createdAt = todo.createdAt;

      await _isar.writeTxn(() async {
        await _isar.todoModels.put(model);
      });
      return (true, null);
    } on IsarError catch (e) {
      return (false, DatabaseFailure(e.message));
    } catch (e) {
      return (false, DatabaseFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
