import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

/// Screen displaying user settings and preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsLoadFailure && previous is! SettingsLoadFailure,
      listener: (context, state) {
        if (state is SettingsLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.userMessage)),
          );
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return switch (state) {
            SettingsInitial() => const SizedBox.shrink(),
            SettingsLoadInProgress() => Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                body: const Center(child: CircularProgressIndicator()),
              ),
            SettingsLoadSuccess(:final preferences) =>
              _buildSettings(context, preferences),
            SettingsLoadFailure(:final failure) => Scaffold(
                appBar: AppBar(title: const Text('Settings')),
                body: Center(
                  child: Text('Error: ${failure.userMessage}'),
                ),
              ),
          };
        },
      ),
    );
  }

  Scaffold _buildSettings(BuildContext context, UserPreferences preferences) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_themeLabel(preferences.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, preferences.themeMode),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: preferences.isNotificationsEnabled,
            onChanged: (value) {
              context
                  .read<SettingsCubit>()
                  .updateNotificationsEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, UserThemeMode current) {
    showDialog<UserThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose Theme'),
        children: UserThemeMode.values.map((mode) {
          return RadioListTile<UserThemeMode>(
            title: Text(_themeLabel(mode)),
            value: mode,
            groupValue: current,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().updateThemeMode(value);
                Navigator.of(context).pop();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _themeLabel(UserThemeMode mode) {
    return switch (mode) {
      UserThemeMode.light => 'Light',
      UserThemeMode.dark => 'Dark',
      UserThemeMode.system => 'System default',
    };
  }
}
