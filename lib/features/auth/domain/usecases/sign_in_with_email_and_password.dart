import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignInWithEmailAndPassword
    extends UseCase<User, SignInWithEmailAndPasswordParams> {
  const SignInWithEmailAndPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(
    SignInWithEmailAndPasswordParams params,
  ) {
    return _repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInWithEmailAndPasswordParams {
  const SignInWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
