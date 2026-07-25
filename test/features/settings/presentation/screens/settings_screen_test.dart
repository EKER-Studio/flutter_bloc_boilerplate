import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:flutter_bloc_boilerplate/core/presentation/cubit/app_theme_cubit.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

/// In-memory [Storage] for use in tests so [AppThemeCubit] (a [HydratedCubit])
/// can be instantiated without real file-system or web storage.
class _TestStorage implements Storage {
  final _store = <String, dynamic>{};

  @override
  dynamic read(String key) => _store[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> close() async {}
}

void main() {
  testWidgets('Settings screen renders with preferences', (tester) async {
    HydratedBloc.storage = _TestStorage();
    final cubit = SettingsCubit(FakeUserPreferencesRepository());

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    cubit.close();
  });
}
