import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_enterprise_starter_kit/core/di/injection.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/register_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/register_cubit.dart';

/// Registers everything the `auth` feature needs. Called once from
/// `core/di/injection.dart`, following the same manual `get_it` pattern as
/// the core registrations.
void configureAuthDependencies() {
  getIt
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<FirebaseAuth>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton<SignInWithEmailAndPassword>(
      () => SignInWithEmailAndPassword(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<RegisterWithEmailAndPassword>(
      () => RegisterWithEmailAndPassword(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()))
    ..registerLazySingleton<AuthCubit>(
      () => AuthCubit(getIt<AuthRepository>(), getIt<SignOut>()),
    )
    ..registerFactory<LoginCubit>(
      () => LoginCubit(getIt<SignInWithEmailAndPassword>()),
    )
    ..registerFactory<RegisterCubit>(
      () => RegisterCubit(getIt<RegisterWithEmailAndPassword>()),
    );
}
