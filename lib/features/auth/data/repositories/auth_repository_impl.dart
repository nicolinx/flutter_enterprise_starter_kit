import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/models/user_mapper.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<User?> get authStateChanges =>
      _remoteDataSource.authStateChanges.map((user) => user?.toDomain());

  @override
  User? get currentUser => _remoteDataSource.currentUser?.toDomain();

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _guard(
    () => _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) => _guard(
    () => _remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    }
  }

  Future<Either<Failure, User>> _guard(
    Future<firebase_auth.User> Function() action,
  ) async {
    try {
      final user = await action();
      return Right(user.toDomain());
    } on ServerException catch (e) {
      return Left(Failure.server(e.message));
    }
  }
}
