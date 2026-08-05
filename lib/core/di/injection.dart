import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_enterprise_starter_kit/core/config/flavor_config.dart';
import 'package:flutter_enterprise_starter_kit/core/network/dio_client.dart';
import 'package:flutter_enterprise_starter_kit/core/network/network_info.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/auth_injection.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Registers every core-layer singleton, then each feature's dependencies.
/// Feature modules add their own `configureXDependencies()` function
/// following the same manual `getIt.registerLazySingleton` pattern (see
/// features/auth/auth_injection.dart) and get called from here.
Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<Connectivity>()),
    )
    ..registerLazySingleton<Dio>(
      () => createDioClient(baseUrl: FlavorConfig.instance.apiBaseUrl),
    );

  configureAuthDependencies();
}
