import '../../../../core/errors/failure.dart';
import '../entities/user_preferences.dart';

/// Repository interface for managing user preferences.
abstract class UserPreferencesRepository {
  /// Watches the user preferences.
  Stream<UserPreferences> watch();

  /// Gets the current user preferences.
  Future<UserPreferences> get();

  /// Updates the theme mode.
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  );

  /// Updates whether notifications are enabled.
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  );
}
