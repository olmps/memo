import 'package:firebase_auth_olmps/firebase_auth_olmps.dart';

abstract class SignOutUC {
  Future<void> run();
}

class SignOutUCImpl implements SignOutUC {
  SignOutUCImpl(this.firebaseAuth);
  final FirebaseAuthentication firebaseAuth;

  @override
  Future<void> run() => firebaseAuth.signOut();
}
