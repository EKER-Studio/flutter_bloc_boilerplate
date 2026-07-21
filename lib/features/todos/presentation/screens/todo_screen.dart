import 'package:flutter/material.dart';

import '../../../settings/presentation/screens/settings_screen.dart';

/// Screen displaying the list of todo items.
class TodoScreen extends StatelessWidget {
  /// Creates a [TodoScreen].
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Todo list view — BLoC integration pending'),
      ),
      floatingActionButton: const SizedBox.shrink(),
    );
  }
}
