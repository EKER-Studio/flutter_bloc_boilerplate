import '../../domain/entities/todo.dart';
import '../models/todo_model.dart';

/// Mapper extensions for [TodoModel].
extension TodoModelMapper on TodoModel {
  /// Converts a [TodoModel] to a [Todo] entity.
  Todo toEntity() {
    return Todo(
      id: id,
      title: title,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }
}

/// Mapper extensions for [Todo] entity.
extension TodoEntityMapper on Todo {
  /// Converts a [Todo] entity to a [TodoModel].
  TodoModel toModel() {
    return TodoModel()
      ..id = id
      ..title = title
      ..isCompleted = isCompleted
      ..createdAt = createdAt;
  }
}
