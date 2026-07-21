import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Registers environment-scoped [Dio] HTTP client instances.
@module
abstract class NetworkModule {
  /// Dio instance configured for the development environment.
  @lazySingleton
  @Environment(Environment.dev)
  Dio get dioDev => _createDio(baseUrl: 'https://dev.api.example.com');

  /// Dio instance configured for the production environment.
  @lazySingleton
  @Environment(Environment.prod)
  Dio get dioProd => _createDio(baseUrl: 'https://api.example.com');

  Dio _createDio({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);

    return dio;
  }
}
