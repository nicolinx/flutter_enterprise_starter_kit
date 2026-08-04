import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockAuthRepository repository;
  late _MockSignOut signOut;
  late StreamController<User?> authStateController;

  const user = User(id: 'uid-123', email: 'test@example.com');

  setUp(() {
    repository = _MockAuthRepository();
    signOut = _MockSignOut();
    authStateController = StreamController<User?>.broadcast();
    when(
      () => repository.authStateChanges,
    ).thenAnswer((_) => authStateController.stream);
  });

  tearDown(() => authStateController.close());

  blocTest<AuthCubit, AuthState>(
    'emits authenticated then unauthenticated as the repository stream emits',
    build: () => AuthCubit(repository, signOut),
    act: (cubit) async {
      authStateController.add(user);
      await Future<void>.delayed(Duration.zero);
      authStateController.add(null);
    },
    expect: () => const [
      AuthState.authenticated(user),
      AuthState.unauthenticated(),
    ],
  );

  test('signOut delegates to the SignOut use case', () async {
    when(
      () => signOut(const NoParams()),
    ).thenAnswer((_) async => const Right(unit));

    final cubit = AuthCubit(repository, signOut);
    await cubit.signOut();

    verify(() => signOut(const NoParams())).called(1);
    await cubit.close();
  });
}
