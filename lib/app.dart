import 'package:flutter/material.dart';

import 'features/todos/presentation/screens/todo_screen.dart';

/// Root widget that applies theme preferences and hosts the home screen.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({super.key});

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
