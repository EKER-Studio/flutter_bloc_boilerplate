@Tags(['golden'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/app.dart';

void main() {
  testWidgets('Todo screen golden test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(App),
      matchesGoldenFile('goldens/todo_screen_placeholder.png'),
    );

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }, skip: !Platform.isMacOS);
}
