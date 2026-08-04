import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Domain representation of a signed-in user. Deliberately minimal — no
/// Firebase types leak past the data layer, so domain/presentation code
/// never imports `package:firebase_auth`.
@freezed
sealed class User with _$User {
  const factory User({required String id, required String email}) = _User;
}
