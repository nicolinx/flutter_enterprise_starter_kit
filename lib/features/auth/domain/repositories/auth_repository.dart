import 'package:flutter_enterprise_starter_kit/core/error/failures.dart';
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  /// Emits the current user whenever sign-in state changes, and `null` when
  /// signed out. Exposed as a stream (rather than a `UseCase`, which is
  /// Future-based) since `AuthCubit` needs to react to changes that can
  /// originate outside this app's own UI (token expiry, sign-out on another
  /// device, etc).
  Stream<User?> get authStateChanges;

  User? get currentUser;

  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();
}
