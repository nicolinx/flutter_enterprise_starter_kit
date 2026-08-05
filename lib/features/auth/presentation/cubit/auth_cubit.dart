import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_enterprise_starter_kit/core/usecase/usecase.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository, this._signOut)
    : super(const AuthState.unknown()) {
    _subscription = _repository.authStateChanges.listen((user) {
      emit(
        user == null
            ? const AuthState.unauthenticated()
            : AuthState.authenticated(user),
      );
    });
  }

  final AuthRepository _repository;
  final SignOut _signOut;
  late final StreamSubscription<void> _subscription;

  Future<void> signOut() => _signOut(const NoParams());

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
