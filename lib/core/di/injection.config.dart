// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:isar_community/isar.dart' as _i214;

import '../../features/settings/data/repositories/user_preferences_repository_impl.dart'
    as _i969;
import '../../features/settings/domain/repositories/user_preferences_repository.dart'
    as _i1060;
import '../../features/settings/presentation/cubit/settings_cubit.dart'
    as _i792;
import '../../features/todos/data/repositories/todo_repository_impl.dart'
    as _i888;
import '../../features/todos/domain/repositories/todo_repository.dart' as _i408;
import '../../features/todos/presentation/bloc/todo_bloc.dart' as _i869;
import '../database/database_module.dart' as _i215;
import '../network/network_module.dart' as _i200;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    final networkModule = _$NetworkModule();
    await gh.singletonAsync<_i214.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i1060.UserPreferencesRepository>(
      () => _i969.UserPreferencesRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dioDev,
      registerFor: {_dev},
    );
    gh.lazySingleton<_i408.TodoRepository>(
      () => _i888.TodoRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dioProd,
      registerFor: {_prod},
    );
    gh.factory<_i792.SettingsCubit>(
      () => _i792.SettingsCubit(gh<_i1060.UserPreferencesRepository>()),
    );
    gh.factory<_i869.TodoBloc>(
      () => _i869.TodoBloc(gh<_i408.TodoRepository>()),
    );
    return this;
  }
}

class _$DatabaseModule extends _i215.DatabaseModule {}

class _$NetworkModule extends _i200.NetworkModule {}
