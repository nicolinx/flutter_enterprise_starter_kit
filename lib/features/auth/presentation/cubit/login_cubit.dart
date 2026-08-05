import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._signIn) : super(const LoginState.initial());

  final SignInWithEmailAndPassword _signIn;

  Future<void> submit({required String email, required String password}) async {
    emit(const LoginState.submitting());

    final result = await _signIn(
      SignInWithEmailAndPasswordParams(email: email, password: password),
    );

    result.match(
      (failure) => emit(LoginState.failure(_messageFor(failure))),
      (_) => emit(const LoginState.success()),
    );
  }

  String _messageFor(Failure failure) =>
      failure.map(
        server: (f) => f.message,
        network: (f) => f.message,
        cache: (f) => f.message,
        unexpected: (f) => f.message,
      );
}
