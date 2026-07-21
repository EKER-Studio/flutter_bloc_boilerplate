import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import 'user_preferences_repository_provider.dart';

part 'user_preferences_notifier.g.dart';

/// Notifier for managing user preferences state.
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  Stream<UserPreferences> build() {
    final repository = ref.watch(userPreferencesRepositoryProvider);
    return repository.watch();
  }

  /// Updates the user's selected theme mode.
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  ) async {
    return await ref
        .read(userPreferencesRepositoryProvider)
        .updateThemeMode(themeMode);
  }

  /// Updates the user's notification preferences.
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return await ref
        .read(userPreferencesRepositoryProvider)
        .updateNotificationsEnabled(isEnabled);
  }
}
