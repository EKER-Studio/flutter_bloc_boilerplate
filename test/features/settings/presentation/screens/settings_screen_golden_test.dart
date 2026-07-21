@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('Settings screen golden test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    final cubit = SettingsCubit(
      FakeUserPreferencesRepository(
        initialPreferences: const UserPreferences(
          themeMode: UserThemeMode.system,
          isNotificationsEnabled: true,
        ),
      ),
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_screen.png'),
    );

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    cubit.close();
  }, skip: !Platform.isMacOS);
}
