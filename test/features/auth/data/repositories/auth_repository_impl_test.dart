import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart'
    as domain;
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class _MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late _MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;
  late _MockFirebaseUser firebaseUser;

  const domainUser = domain.User(id: 'uid-123', email: 'test@example.com');

  setUp(() {
    dataSource = _MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
    firebaseUser = _MockFirebaseUser();
    when(() => firebaseUser.uid).thenReturn('uid-123');
    when(() => firebaseUser.email).thenReturn('test@example.com');
  });

  group('signInWithEmailAndPassword', () {
    test('returns Right(User) on success', () async {
      when(
        () => dataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => firebaseUser);

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(const Right<Failure, domain.User>(domainUser)));
    });

    test('returns Left(Failure) when the data source throws', () async {
      when(
        () => dataSource.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ServerException('Incorrect email or password.'));

      final result = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(
        result,
        equals(
          const Left<Failure, domain.User>(
            Failure.server('Incorrect email or password.'),
          ),
        ),
      );
    });
  });

  group('signOut', () {
    test('returns Right(unit) on success', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      final result = await repository.signOut();

      expect(result, equals(const Right<Failure, Unit>(unit)));
    });

    test('returns Left(Failure) when the data source throws', () async {
      when(
        () => dataSource.signOut(),
      ).thenThrow(const ServerException('Failed to sign out'));

      final result = await repository.signOut();

      expect(
        result,
        equals(
          const Left<Failure, Unit>(Failure.server('Failed to sign out')),
        ),
      );
    });
  });

  group('authStateChanges', () {
    test('maps a Firebase user to the domain User', () async {
      when(
        () => dataSource.authStateChanges,
      ).thenAnswer((_) => Stream.value(firebaseUser));

      final emitted = await repository.authStateChanges.first;

      expect(emitted, domainUser);
    });

    test('maps null (signed out) to null', () async {
      when(
        () => dataSource.authStateChanges,
      ).thenAnswer((_) => Stream<firebase_auth.User?>.value(null));

      final emitted = await repository.authStateChanges.first;

      expect(emitted, isNull);
    });
  });
}
