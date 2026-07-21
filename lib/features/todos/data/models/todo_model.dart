import 'package:isar_community/isar.dart';

part 'todo_model.g.dart';

/// Persistent representation of a [Todo] domain entity.
@collection
class TodoModel {
  /// The unique identifier.
  Id id = Isar.autoIncrement;

  /// The title of the todo.
  late String title;

  /// Whether the todo is completed.
  bool isCompleted = false;

  /// The date and time when the todo was created.
  @Index()
  late DateTime createdAt;
}
