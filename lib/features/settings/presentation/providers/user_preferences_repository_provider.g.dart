// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the [UserPreferencesRepository].

@ProviderFor(userPreferencesRepository)
final userPreferencesRepositoryProvider = UserPreferencesRepositoryProvider._();

/// Provider for the [UserPreferencesRepository].

final class UserPreferencesRepositoryProvider
    extends
        $FunctionalProvider<
          UserPreferencesRepository,
          UserPreferencesRepository,
          UserPreferencesRepository
        >
    with $Provider<UserPreferencesRepository> {
  /// Provider for the [UserPreferencesRepository].
  UserPreferencesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserPreferencesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserPreferencesRepository create(Ref ref) {
    return userPreferencesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPreferencesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPreferencesRepository>(value),
    );
  }
}

String _$userPreferencesRepositoryHash() =>
    r'31d1fe8f690b4eab93a9802ac0abd96c88a015a8';
