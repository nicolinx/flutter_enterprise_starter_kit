import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/register_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/register_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/register_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegister extends Mock implements RegisterWithEmailAndPassword {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RegisterWithEmailAndPasswordParams(email: '', password: ''),
    );
  });

  late _MockRegister register;

  setUp(() {
    register = _MockRegister();
  });

  const user = User(id: 'uid-123', email: 'test@example.com');

  blocTest<RegisterCubit, RegisterState>(
    'emits [submitting, success] when registration succeeds',
    build: () => RegisterCubit(register),
    setUp: () {
      when(
        () => register(any()),
      ).thenAnswer((_) async => const Right(user));
    },
    act: (cubit) =>
        cubit.submit(email: 'test@example.com', password: 'password123'),
    expect: () => const [RegisterState.submitting(), RegisterState.success()],
  );

  blocTest<RegisterCubit, RegisterState>(
    'emits [submitting, failure] when registration fails',
    build: () => RegisterCubit(register),
    setUp: () {
      when(() => register(any())).thenAnswer(
        (_) async => const Left(
          Failure.server('An account already exists for that email.'),
        ),
      );
    },
    act: (cubit) =>
        cubit.submit(email: 'test@example.com', password: 'password123'),
    expect: () => const [
      RegisterState.submitting(),
      RegisterState.failure('An account already exists for that email.'),
    ],
  );
}
