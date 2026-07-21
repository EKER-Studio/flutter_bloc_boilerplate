import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_boilerplate/features/todos/presentation/widgets/add_todo_fab.dart';

void main() {
  testWidgets('AddTodoFab shows dialog and calls onAdd on submit', (
    tester,
  ) async {
    String? addedTitle;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddTodoFab(
            onAdd: (title) async {
              addedTitle = title;
            },
          ),
        ),
      ),
    );

    // 1. Tap the FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 2. Verify dialog is shown
    expect(find.text('New Task'), findsOneWidget);

    // 3. Enter text
    await tester.enterText(find.byType(TextFormField), 'Buy milk');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    // 4. Verify callback was called with correct title
    expect(addedTitle, 'Buy milk');
    expect(find.text('New Task'), findsNothing);
  });

  testWidgets('AddTodoFab validation fails for empty title', (tester) async {
    bool onAddCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddTodoFab(
            onAdd: (title) async {
              onAddCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Tap Add without entering text
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify validation error is shown and callback not called
    expect(find.text('Title cannot be empty'), findsOneWidget);
    expect(onAddCalled, isFalse);

    // Enter only whitespace
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Title cannot be empty'), findsOneWidget);
    expect(onAddCalled, isFalse);
  });

  testWidgets('AddTodoFab dialog closes on cancel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AddTodoFab(onAdd: (title) async {})),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsNothing);
  });
}
