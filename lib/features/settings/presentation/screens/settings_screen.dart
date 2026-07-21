import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../providers/user_preferences_notifier.dart';

/// Screen displaying user settings and preferences.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load settings',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error is Failure ? error.userMessage : error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(userPreferencesProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (preferences) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            SegmentedButton<UserThemeMode>(
              segments: const [
                ButtonSegment<UserThemeMode>(
                  value: UserThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System'),
                ),
                ButtonSegment<UserThemeMode>(
                  value: UserThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment<UserThemeMode>(
                  value: UserThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {preferences.themeMode},
              onSelectionChanged: (selection) =>
                  _updateThemeMode(context, ref, selection.single),
            ),
            const Divider(height: 24),
            SwitchListTile(
              title: const Text('Notifications'),
              secondary: const Icon(Icons.notifications_outlined),
              value: preferences.isNotificationsEnabled,
              onChanged: (value) async {
                final (success, failure) = await ref
                    .read(userPreferencesProvider.notifier)
                    .updateNotificationsEnabled(value);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        failure?.userMessage ?? 'Failed to update preferences',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateThemeMode(
    BuildContext context,
    WidgetRef ref,
    UserThemeMode value,
  ) async {
    final (success, failure) = await ref
        .read(userPreferencesProvider.notifier)
        .updateThemeMode(value);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure?.userMessage ?? 'Failed to update theme mode'),
        ),
      );
    }
  }
}
