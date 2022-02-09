import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/http_exception.dart';
import 'package:memo/data/repositories/paths.dart' as paths;
import 'package:memo/data/serializers/user_serializer.dart';
import 'package:memo/domain/models/user.dart';

/// Handles all IO and serialization operations associated with [User]s.
abstract class UserRepository {
  /// Streams the current signed-in [User] and any changes made to it.
  Stream<User> listenToUserInfo();

  Future<User> getUserInfo();
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._auth, this._db);

  final firebase_auth.FirebaseAuth _auth;
  final FirestoreDatabase _db;

  final _userSerializer = UserSerializer();

  @override
  Stream<User> listenToUserInfo() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while listening to user info');
    }

    return _db
        .listenToDocument(id: currentUserId, collectionPath: paths.users)
        .map((rawUser) => _userSerializer.from(rawUser!.data))
        .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
  }

  @override
  Future<User> getUserInfo() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while fetching user info');
    }

    try {
      final rawUser = await _db.get(id: currentUserId, collectionPath: paths.users);
      return _userSerializer.from(rawUser!.data);
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }
}
