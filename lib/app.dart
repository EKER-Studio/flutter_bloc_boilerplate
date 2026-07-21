import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/domain/entities/user_preferences.dart';
import 'features/settings/presentation/providers/user_preferences_notifier.dart';
import 'features/todos/presentation/screens/todo_screen.dart';

/// Root widget that applies theme preferences and hosts the home screen.
class App extends ConsumerWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider).value;

    return MaterialApp(
      title: 'Flutter Riverpod Boilerplate',
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
      themeMode: _toFlutterThemeMode(
        preferences?.themeMode ?? UserThemeMode.system,
      ),
      home: const TodoScreen(),
    );
  }

  ThemeMode _toFlutterThemeMode(UserThemeMode themeMode) {
    return switch (themeMode) {
      UserThemeMode.light => ThemeMode.light,
      UserThemeMode.dark => ThemeMode.dark,
      UserThemeMode.system => ThemeMode.system,
    };
  }
}
