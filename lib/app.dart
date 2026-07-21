import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/todos/presentation/bloc/todo_bloc.dart';
import 'features/todos/presentation/bloc/todo_event.dart';
import 'features/todos/presentation/screens/todo_screen.dart';

/// Root widget that configures BLoCs, applies theme preferences, and hosts the
/// home screen.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoBloc>(
          create: (_) => GetIt.instance<TodoBloc>()..add(const WatchTodos()),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => GetIt.instance<SettingsCubit>(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BLoC Boilerplate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const TodoScreen(),
    );
  }
}
