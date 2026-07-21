@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen_detail.dart';

void main() {
  group('Todo Detail Screen Golden Tests', () {
    testWidgets('Placeholder state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;

      await tester.pumpWidget(
        const MaterialApp(home: TodoDetailScreen(todoId: 1)),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TodoDetailScreen),
        matchesGoldenFile('goldens/todo_detail_placeholder.png'),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }, skip: !Platform.isMacOS);
}
