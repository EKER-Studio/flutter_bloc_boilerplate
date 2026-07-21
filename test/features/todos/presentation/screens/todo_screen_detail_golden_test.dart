@Tags(['golden'])
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_detail_notifier.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/providers/todo_repository_provider.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/screens/todo_screen_detail.dart';

import '../../../../helpers/fake_todo_repository.dart';

// Helper notifiers for simulating loading and error states deterministically.
class LoadingTodoDetailNotifier extends TodoDetail {
  @override
  Stream<Todo?> build(int id) {
    return Completer<Todo?>().future.asStream();
  }
}

class ErrorTodoDetailNotifier extends TodoDetail {
  @override
  Stream<Todo?> build(int id) {
    return Stream.error(Exception('Database connection error'));
  }
}

void main() {
  late FakeTodoRepository repository;
  final frozenDate = DateTime(2025, 1, 1, 10, 0);

  setUp(() {
    repository = FakeTodoRepository(clock: () => frozenDate);
  });

  tearDown(() {
    repository.dispose();
  });

  group('Todo Detail Screen Golden Tests', () {
    testWidgets('Loading state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            todoDetailProvider(
              1,
            ).overrideWith(() => LoadingTodoDetailNotifier()),
          ],
          child: const MaterialApp(home: TodoDetailScreen(todoId: 1)),
        ),
      );

      // Pump to trigger build, but do not pumpAndSettle since loading is infinite
      await tester.pump();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_loading.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Error state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoRepositoryProvider.overrideWithValue(repository),
            todoDetailProvider(1).overrideWith(() => ErrorTodoDetailNotifier()),
          ],
          child: const MaterialApp(home: TodoDetailScreen(todoId: 1)),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_error.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Todo does not exist state (null todo)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: TodoDetailScreen(todoId: 999)),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_not_found.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Active Todo state (In progress)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      final todo = Todo(
        id: 1,
        title: 'Write unit tests',
        isCompleted: false,
        createdAt: frozenDate,
      );
      repository = FakeTodoRepository(
        initialTodos: [todo],
        clock: () => frozenDate,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: TodoDetailScreen(todoId: 1)),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_active.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Completed Todo state (Done)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      final todo = Todo(
        id: 2,
        title: 'Configure linter and CI',
        isCompleted: true,
        createdAt: frozenDate,
      );
      repository = FakeTodoRepository(
        initialTodos: [todo],
        clock: () => frozenDate,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(home: TodoDetailScreen(todoId: 2)),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_completed.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }, skip: !Platform.isMacOS);
}
