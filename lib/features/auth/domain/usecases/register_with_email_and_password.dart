import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class RegisterWithEmailAndPassword
    extends UseCase<User, RegisterWithEmailAndPasswordParams> {
  const RegisterWithEmailAndPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(
    RegisterWithEmailAndPasswordParams params,
  ) {
    return _repository.registerWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterWithEmailAndPasswordParams {
  const RegisterWithEmailAndPasswordParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
