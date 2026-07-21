@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/widgets/todo_list_item.dart';

void main() {
  final frozenDate = DateTime(2025, 1, 1, 10, 0);

  group('TodoListItem Golden Tesfluttets', () {
    testWidgets('Active state', (tester) async {
      tester.view.physicalSize = const Size(500, 100);
      tester.view.devicePixelRatio = 3.0;

      final todo = Todo(
        id: 1,
        title: 'Active Todo',
        isCompleted: false,
        createdAt: frozenDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListItem(todo: todo, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );

      await expectLater(
        find.byType(TodoListItem),
        matchesGoldenFile('goldens/todo_list_item_active.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Completed state', (tester) async {
      tester.view.physicalSize = const Size(500, 100);
      tester.view.devicePixelRatio = 3.0;

      final todo = Todo(
        id: 1,
        title: 'Completed Todo',
        isCompleted: true,
        createdAt: frozenDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListItem(todo: todo, onToggle: () {}, onDelete: () {}),
          ),
        ),
      );

      await expectLater(
        find.byType(TodoListItem),
        matchesGoldenFile('goldens/todo_list_item_completed.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }, skip: !Platform.isMacOS);
}
