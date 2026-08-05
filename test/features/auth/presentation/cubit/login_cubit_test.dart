import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignIn extends Mock implements SignInWithEmailAndPassword {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SignInWithEmailAndPasswordParams(email: '', password: ''),
    );
  });

  late _MockSignIn signIn;

  setUp(() {
    signIn = _MockSignIn();
  });

  const user = User(id: 'uid-123', email: 'test@example.com');

  blocTest<LoginCubit, LoginState>(
    'emits [submitting, success] when sign-in succeeds',
    build: () => LoginCubit(signIn),
    setUp: () {
      when(
        () => signIn(any()),
      ).thenAnswer((_) async => const Right(user));
    },
    act: (cubit) =>
        cubit.submit(email: 'test@example.com', password: 'password123'),
    expect: () => const [LoginState.submitting(), LoginState.success()],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [submitting, failure] when sign-in fails',
    build: () => LoginCubit(signIn),
    setUp: () {
      when(() => signIn(any())).thenAnswer(
        (_) async =>
            const Left(Failure.server('Incorrect email or password.')),
      );
    },
    act: (cubit) =>
        cubit.submit(email: 'test@example.com', password: 'wrong'),
    expect: () => const [
      LoginState.submitting(),
      LoginState.failure('Incorrect email or password.'),
    ],
  );

  test('passes the given email and password to the use case', () async {
    when(() => signIn(any())).thenAnswer((_) async => const Right(user));
    final cubit = LoginCubit(signIn);

    await cubit.submit(email: 'test@example.com', password: 'password123');

    final captured =
        verify(() => signIn(captureAny())).captured.single
            as SignInWithEmailAndPasswordParams;
    expect(captured.email, 'test@example.com');
    expect(captured.password, 'password123');

    await cubit.close();
  });
}
