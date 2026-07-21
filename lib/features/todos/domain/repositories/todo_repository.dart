import '../../../../core/errors/failure.dart';
import '../entities/todo.dart';

/// Repository interface for managing todo items.
abstract class TodoRepository {
  /// Watches all todo items.
  Stream<List<Todo>> watchAll();

  /// Watches a specific todo item by its ID.
  Stream<Todo?> watchById(int id);

  /// Gets all todo items as a one-shot snapshot.
  ///
  /// Not currently called by any notifier — [watchAll] is used instead for
  /// reactive updates. Kept on the interface for one-shot use cases such as
  /// CSV/JSON export or pagination cursors, where a live stream isn't
  /// needed. Remove if no such use case materializes.
  Future<List<Todo>> getAll();

  /// Adds a new todo item with the given title.
  Future<(bool success, Failure? failure)> add({required String title});

  /// Toggles the completion status of a todo item.
  Future<(bool success, Failure? failure)> toggleCompleted({required int id});

  /// Deletes a todo item by its ID.
  Future<(bool success, Failure? failure)> delete({required int id});

  /// Re-inserts a previously deleted [todo], preserving its original id,
  /// title, completion state, and creation timestamp. Used to implement
  /// "Undo" after a delete action.
  Future<(bool success, Failure? failure)> restore(Todo todo);
}
