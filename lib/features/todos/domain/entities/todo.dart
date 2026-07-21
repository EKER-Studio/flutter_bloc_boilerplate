/// Domain entity representing a single todo item.
class Todo {
  /// Creates a [Todo] instance.
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  /// The unique identifier of the todo.
  final int id;

  /// The title of the todo.
  final String title;

  /// Whether the todo is completed.
  final bool isCompleted;

  /// The date and time when the todo was created.
  final DateTime createdAt;

  /// Creates a copy of this object with the given fields replaced with the new values.
  Todo copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            other.id == id &&
            other.title == title &&
            other.isCompleted == isCompleted &&
            other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, isCompleted, createdAt);
}
