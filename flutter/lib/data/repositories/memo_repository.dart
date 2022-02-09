import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/http_exception.dart';
import 'package:memo/data/repositories/paths.dart' as paths;
import 'package:memo/data/serializers/collection_execution_serializer.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/models/collection_execution.dart';
import 'package:memo/domain/models/memo.dart';

class MemoRepositoryImpl {
  MemoRepositoryImpl(this._db, this._auth);

  final firebase_auth.FirebaseAuth _auth;
  final FirestoreDatabase _db;

  final _memoSerializer = MemoSerializer();
  final _memoExecutionMetadataSerializer = MemoExecutionRecallMetadataSerializer();

  Future<List<Memo>> getMemosByIds({
    required bool isPrivate,
    required String collectionId,
    required List<String> ids,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while getting memos by their ids');
    }

    try {
      final memosPath = isPrivate
          ? paths.userCollectionMemos(userId: currentUserId, collectionId: collectionId)
          : paths.collectionsMemos(collectionId: collectionId);

      // TODO(matuella): Does queryIn with documentId works for more than 10 docs? Test it -> QueryFilter(field: FieldPath.documentId, whereIn: ids);
      final responses = await Future.wait(ids.map((id) => _db.get(id: id, collectionPath: memosPath)).toList());

      return responses.map((doc) {
        if (doc == null) {
          throw InconsistentStateError.repository('Missing an expected memo when retrieving by their ids: $ids');
        }

        return _memoSerializer.from(doc.data);
      }).toList();
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  Future<void> addMemo({required String userId, required String collectionId, required Memo memo}) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while getting memos by their ids');
    }

    try {
      await _db.runInTransaction(() async {
        final newMemo = _db.set(
          collectionPath: paths.userCollectionMemos(userId: userId, collectionId: collectionId),
          data: _memoSerializer.to(memo),
          id: memo.id,
          shouldMerge: false,
        );

        await Future.wait([
          newMemo,
          _updateAddMemoReferences(userId: userId, collectionId: collectionId, memoId: memo.id),
        ]);
      });
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  Future<void> updateMemo({required String userId, required String collectionId, required Memo memo}) async {
    try {
      await _db.update(
        collectionPath: paths.userCollectionMemos(userId: userId, collectionId: collectionId),
        data: _memoSerializer.to(memo),
        id: memo.id,
      );
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  Future<void> deleteMemoById({required String userId, required String collectionId, required String id}) async {
    try {
      await _db.runInTransaction(() async {
        final deleteMemo = _db.delete(
          id: id,
          collectionPath: paths.userCollectionMemos(userId: userId, collectionId: collectionId),
        );

        await Future.wait([
          deleteMemo,
          _updateDeleteMemoReferences(userId: userId, collectionId: collectionId, memoId: id),
        ]);
      });
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  Future<void> _updateAddMemoReferences({
    required String userId,
    required String collectionId,
    required String memoId,
  }) async {
    final executionPath = paths.userCollectionsExecutions(userId: userId);
    final execution = await _db.get(id: collectionId, collectionPath: executionPath);
    Future<void>? executionUpdate;
    if (execution != null) {
      executionUpdate = _db.set(
        collectionPath: executionPath,
        data: <String, dynamic>{
          'executions': {
            memoId: _memoExecutionMetadataSerializer.to(MemoExecutionRecallMetadata.blank(id: memoId)),
          },
        },
        id: memoId,
      );
    }

    final collectionUpdate = _db.set(
      collectionPath: paths.userCollections(userId: userId),
      id: collectionId,
      data: <String, dynamic>{
        'memosAmount': FieldValue.increment(1),
        'memosOrder': FieldValue.arrayUnion(<String>[memoId]),
      },
    );

    await Future.wait([
      collectionUpdate,
      if (executionUpdate != null) executionUpdate,
    ]);
  }

  Future<void> _updateDeleteMemoReferences({
    required String userId,
    required String collectionId,
    required String memoId,
  }) async {
    final executionPath = paths.userCollectionsExecutions(userId: userId);
    final execution = await _db.get(id: collectionId, collectionPath: executionPath);
    Future<void>? executionUpdate;
    if (execution != null) {
      executionUpdate = _db.set(
        collectionPath: executionPath,
        data: <String, dynamic>{
          // TODO: How to remove a object key without sending it whole?
          // 'executions': {
          //   memoId: _memoExecutionMetadataSerializer.to(MemoExecutionRecallMetadata.blank(id: memoId)),
          // },
        },
        id: memoId,
      );
    }

    final collectionUpdate = _db.set(
      collectionPath: paths.userCollections(userId: userId),
      id: collectionId,
      data: <String, dynamic>{
        'memosAmount': FieldValue.increment(-1),
        'memosOrder': FieldValue.arrayRemove(<String>[memoId]),
      },
    );

    await Future.wait([
      collectionUpdate,
      if (executionUpdate != null) executionUpdate,
    ]);
  }
}
