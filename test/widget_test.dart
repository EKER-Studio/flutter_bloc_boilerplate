import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen.dart';

import 'helpers/fake_todo_repository.dart';
import 'helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TodoBloc>(
            create: (_) =>
                TodoBloc(FakeTodoRepository())..add(const WatchTodos()),
          ),
          BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(FakeUserPreferencesRepository()),
          ),
        ],
        child: const MaterialApp(home: TodoScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
