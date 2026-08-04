import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Global sign-in awareness, driven by `AuthRepository.authStateChanges`.
/// The router reads this to decide whether to show the app or the login
/// flow — it is not where login/register form state lives (see
/// `LoginCubit`/`RegisterCubit`).
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthUnknown;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
}
