import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
sealed class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = RegisterInitial;
  const factory RegisterState.submitting() = RegisterSubmitting;
  const factory RegisterState.success() = RegisterSuccess;
  const factory RegisterState.failure(String message) = RegisterFailure;
}
