import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';

sealed class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoadInProgress extends SettingsState {
  const SettingsLoadInProgress();
}

class SettingsLoadSuccess extends SettingsState {
  const SettingsLoadSuccess(this.preferences);

  final UserPreferences preferences;
}

class SettingsLoadFailure extends SettingsState {
  const SettingsLoadFailure(this.failure);

  final Failure failure;
}
