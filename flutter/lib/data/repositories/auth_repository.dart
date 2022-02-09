import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:memo/domain/models/user.dart';

/// Handles all IO and serialization operations associated with the current user authentication.
abstract class AuthRepository {
  /// Streams the current [UserAuth], which emits a new auth when any authentication event occurs.
  Stream<UserAuth?> listenToAuth();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth);

  final firebase_auth.FirebaseAuth _auth;

  @override
  Stream<UserAuth?> listenToAuth() {
    return _auth.idTokenChanges().asyncMap((user) async {
      try {
        if (user != null) {
          final token = await user.getIdTokenResult();
          return UserAuth(id: user.uid, token: token.token!);
        }

        return null;
      } on firebase_auth.FirebaseAuthException {
        // Force user sign out if it fails to get its id token
        await _auth.signOut();
        rethrow;
      }
    });
  }
}
