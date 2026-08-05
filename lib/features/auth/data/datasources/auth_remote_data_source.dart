import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_enterprise_starter_kit/core/error/exceptions.dart';

/// Thin wrapper over `FirebaseAuth` that only ever throws this app's typed
/// exceptions — nothing above this layer needs to know about
/// `FirebaseAuthException` or its dozens of `code` values.
abstract class AuthRemoteDataSource {
  Stream<firebase_auth.User?> get authStateChanges;

  firebase_auth.User? get currentUser;

  Future<firebase_auth.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<firebase_auth.User> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._firebaseAuth);

  final firebase_auth.FirebaseAuth _firebaseAuth;

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  @override
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<firebase_auth.User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _run(
    () => _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  @override
  Future<firebase_auth.User> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) => _run(
    () => _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on Exception {
      throw const ServerException('Failed to sign out');
    }
  }

  Future<firebase_auth.User> _run(
    Future<firebase_auth.UserCredential> Function() action,
  ) async {
    try {
      final credential = await action();
      final user = credential.user;
      if (user == null) {
        throw const ServerException('No user returned by Firebase');
      }
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_messageFor(e.code));
    }
  }

  String _messageFor(String code) => switch (code) {
    'invalid-email' => 'That email address is invalid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' || 'wrong-password' || 'invalid-credential' =>
      'Incorrect email or password.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'That password is too weak.',
    'operation-not-allowed' =>
      'Email/password sign-in is not enabled for this Firebase project.',
    _ => _unhandled(code),
  };

  /// Codes not covered above still get a generic user-facing message, but we
  /// log the real code so it's not lost — the alternative is a silent
  /// "Authentication failed" with no way to diagnose it from the UI alone.
  String _unhandled(String code) {
    if (kDebugMode) {
      debugPrint('Unhandled FirebaseAuthException code: $code');
    }
    return 'Authentication failed. Please try again.';
  }
}
