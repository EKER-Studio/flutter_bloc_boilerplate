@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen_detail.dart';

import '../../../../helpers/fake_todo_repository.dart';

void main() {
  group('Todo Detail Screen Golden Tests', () {
    testWidgets('Detail state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      final repository = FakeTodoRepository(
        initialTodos: [
          Todo(
            id: 1,
            title: 'Test Todo',
            isCompleted: false,
            createdAt: DateTime(2025, 6, 15, 14, 30),
          ),
        ],
      );

      await tester.pumpWidget(
        BlocProvider.value(
          value: TodoBloc(repository)..add(const WatchTodos()),
          child: const MaterialApp(home: TodoDetailScreen(todoId: 1)),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }, skip: !Platform.isMacOS);
}
