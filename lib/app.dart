import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/presentation/cubit/app_theme_cubit.dart';
import 'core/presentation/cubit/app_theme_state.dart';
import 'features/settings/domain/entities/user_preferences.dart';
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
          create: (_) => GetIt.instance<SettingsCubit>()..init(),
        ),
        BlocProvider<AppThemeCubit>(
          create: (_) => GetIt.instance<AppThemeCubit>(),
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
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
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
          themeMode: _mapThemeMode(state.mode),
          home: const TodoScreen(),
        );
      },
    );
  }
}

ThemeMode _mapThemeMode(UserThemeMode mode) {
  return switch (mode) {
    UserThemeMode.light => ThemeMode.light,
    UserThemeMode.dark => ThemeMode.dark,
    UserThemeMode.system => ThemeMode.system,
  };
}
