import 'package:firebase_auth_olmps/firebase_auth_olmps.dart';
import 'package:flutter/material.dart';
import 'package:memo/data/repositories/auth_repository.dart';
import 'package:memo/domain/models/user.dart';

abstract class SignInUC {
  Future<void> run(SignInMethod method, BuildContext context);
}

enum SignInMethod { apple, github, google }

class SignInUCImpl implements SignInUC {
  SignInUCImpl(AuthRepository authRepo, this.firebaseAuth) {
    authState = authRepo.listenToAuth();
  }

  late final Stream<UserAuth?> authState;

  final FirebaseAuthentication firebaseAuth;

  @override
  Future<void> run(SignInMethod method, BuildContext context) async {
    try {
      switch (method) {
        case SignInMethod.apple:
          await firebaseAuth.signInWithApple();
          break;
        case SignInMethod.github:
          await firebaseAuth.signInWithGithub(context);
          break;
        case SignInMethod.google:
          await firebaseAuth.signInWithGoogle();
          break;
      }
    } catch (exc) {
      // TODO(matuella): Error handling
    }
  }
}
