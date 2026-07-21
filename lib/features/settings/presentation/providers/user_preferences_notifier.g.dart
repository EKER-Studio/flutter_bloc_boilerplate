// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing user preferences state.

@ProviderFor(UserPreferencesNotifier)
final userPreferencesProvider = UserPreferencesNotifierProvider._();

/// Notifier for managing user preferences state.
final class UserPreferencesNotifierProvider
    extends $StreamNotifierProvider<UserPreferencesNotifier, UserPreferences> {
  /// Notifier for managing user preferences state.
  UserPreferencesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesNotifierHash();

  @$internal
  @override
  UserPreferencesNotifier create() => UserPreferencesNotifier();
}

String _$userPreferencesNotifierHash() =>
    r'2d70fa08f6b7bd66c5d0841adbf25594fdec3976';

/// Notifier for managing user preferences state.

abstract class _$UserPreferencesNotifier
    extends $StreamNotifier<UserPreferences> {
  Stream<UserPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserPreferences>, UserPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserPreferences>, UserPreferences>,
              AsyncValue<UserPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
