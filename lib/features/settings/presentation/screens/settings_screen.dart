import 'package:flutter/material.dart';

/// Screen displaying user settings and preferences.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings view — BLoC integration pending'),
      ),
    );
  }
}
