import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/widgets/todo_list_item.dart';

void main() {
  final tDate = DateTime(2024, 1, 1, 12, 0);
  final tTodo = Todo(
    id: 1,
    title: 'Test Todo',
    isCompleted: false,
    createdAt: tDate,
  );

  testWidgets('TodoListItem displays title and date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoListItem(todo: tTodo, onToggle: () {}, onDelete: () {}),
        ),
      ),
    );

    expect(find.text('Test Todo'), findsOneWidget);
    expect(find.text('2024-01-01 12:00'), findsOneWidget);
  });

  testWidgets('TodoListItem calls onToggle when checkbox is tapped', (
    tester,
  ) async {
    bool toggled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoListItem(
            todo: tTodo,
            onToggle: () => toggled = true,
            onDelete: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    expect(toggled, isTrue);
  });

  testWidgets('TodoListItem calls onDelete when dismissed', (tester) async {
    bool deleted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoListItem(
            todo: tTodo,
            onToggle: () {},
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    // Swipe to delete (DismissDirection.endToStart)
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });
}
