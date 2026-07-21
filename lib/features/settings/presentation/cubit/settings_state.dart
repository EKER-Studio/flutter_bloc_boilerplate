import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';

/// States emitted by [SettingsCubit].
sealed class SettingsState {
  const SettingsState();
}

/// Initial state before [SettingsCubit.init()] is called.
class SettingsInitial extends SettingsState {
  /// Creates a [SettingsInitial] state.
  const SettingsInitial();
}

/// Emitted while preferences are being loaded.
class SettingsLoadInProgress extends SettingsState {
  /// Creates a [SettingsLoadInProgress] state.
  const SettingsLoadInProgress();
}

/// Emitted when preferences were loaded successfully.
class SettingsLoadSuccess extends SettingsState {
  /// Creates a [SettingsLoadSuccess] state with the given [preferences].
  const SettingsLoadSuccess(this.preferences);

  /// The loaded user preferences.
  final UserPreferences preferences;
}

/// Emitted when preferences failed to load or update.
class SettingsLoadFailure extends SettingsState {
  /// Creates a [SettingsLoadFailure] state with the given [failure].
  const SettingsLoadFailure(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
