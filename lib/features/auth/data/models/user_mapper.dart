import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_enterprise_starter_kit/features/auth/domain/entities/user.dart';

/// Maps the Firebase SDK's `User` straight to the domain entity. No
/// intermediate Freezed/`json_serializable` model is needed here — unlike
/// the `posts` feature, this data doesn't come from a JSON API response,
/// the Firebase SDK already hands back a typed object.
extension FirebaseUserMapper on firebase_auth.User {
  User toDomain() => User(id: uid, email: email ?? '');
}
