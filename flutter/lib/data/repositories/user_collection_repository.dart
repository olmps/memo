import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/http_exception.dart';
import 'package:memo/data/repositories/paths.dart' as paths;
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/domain/models/collection.dart';

class UserCollectionRepositoryImpl {
  UserCollectionRepositoryImpl(this._auth, this._db);

  final firebase_auth.FirebaseAuth _auth;
  final FirestoreDatabase _db;

  final _collectionSerializer = CollectionSerializer();

  CursorPaginatedResult<Collection> listenToPaginatedUserCollections({required int pageSize}) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while paginated-listening to the user collection');
    }

    // TODO(matuella): add error interceptor to the `results` stream.
    // .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
    return _db.getAllPaginated(
      collectionPath: paths.userCollections(userId: currentUserId),
      pageSize: pageSize,
      resultDeserializer: (doc) => _collectionSerializer.from(doc.data),
      sorts: [QuerySort(field: CollectionKeys.name)],
      listenToChanges: true,
    );
  }

  Future<void> setUserCollection({required String userId, required Collection collection}) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw InconsistentStateError.repository('Missing required user while updating user collection');
      }

      await _db.set(
        collectionPath: paths.userCollections(userId: userId),
        data: _collectionSerializer.to(collection),
        id: collection.id,
      );
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  // TODO(matuella): Cloud function that recursivelly deletes collection and all of its memos
  // The CF must take into consideration the
  // Future<void> deleteUserCollectionById({required String id}) {}

  Stream<Collection?> listenToUserCollection({required String id}) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while listening to the user collection');
    }

    return _db
        .listenToDocument(id: id, collectionPath: paths.userCollections(userId: currentUserId))
        .map((collection) => collection != null ? _collectionSerializer.from(collection.data) : null)
        .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
  }
}
