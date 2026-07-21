import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/isar_provider.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';
import '../../domain/repositories/user_preferences_repository.dart';

part 'user_preferences_repository_provider.g.dart';

/// Provider for the [UserPreferencesRepository].
@Riverpod(keepAlive: true)
UserPreferencesRepository userPreferencesRepository(Ref ref) {
  return UserPreferencesRepositoryImpl(ref.watch(isarProvider));
}
