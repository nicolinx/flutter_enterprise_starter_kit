import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/register_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._register) : super(const RegisterState.initial());

  final RegisterWithEmailAndPassword _register;

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    emit(const RegisterState.submitting());

    final result = await _register(
      RegisterWithEmailAndPasswordParams(email: email, password: password),
    );

    result.match(
      (failure) => emit(RegisterState.failure(_messageFor(failure))),
      (_) => emit(const RegisterState.success()),
    );
  }

  String _messageFor(Failure failure) => failure.map(
    server: (f) => f.message,
    network: (f) => f.message,
    cache: (f) => f.message,
    unexpected: (f) => f.message,
  );
}
