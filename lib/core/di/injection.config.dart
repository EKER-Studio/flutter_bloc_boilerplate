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
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dioDev,
      registerFor: {_dev},
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dioProd,
      registerFor: {_prod},
    );
    return this;
  }
}

class _$DatabaseModule extends _i215.DatabaseModule {}

class _$NetworkModule extends _i200.NetworkModule {}
