import 'package:collection/collection.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/core/faults/exceptions/http_exception.dart';
import 'package:memo/data/repositories/paths.dart' as paths;
import 'package:memo/data/serializers/collection_execution_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection_execution.dart';
import 'package:memo/domain/models/memo_execution.dart';

class ExecutionRepositoryImpl {
  ExecutionRepositoryImpl(this._db, this._auth);

  final firebase_auth.FirebaseAuth _auth;
  final FirestoreDatabase _db;

  final _memoExecutionsSerializer = MemoExecutionSerializer();
  final _collectionExecutionsSerializer = CollectionExecutionSerializer();
  final _memoRecallMetadataSerializer = MemoExecutionRecallMetadataSerializer();

  CursorPaginatedResult<CollectionExecution> listenToPaginatedCollectionExecutions({required int pageSize}) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository(
          'Missing required user while listening to paginated collection executions');
    }

    // TODO(matuella): add error interceptor to the `results` stream.
    // .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
    return _db.getAllPaginated(
      collectionPath: paths.userCollectionsExecutions(userId: currentUserId),
      resultDeserializer: (doc) => _collectionExecutionsSerializer.from(doc.data),
      pageSize: pageSize,
      listenToChanges: true,
    );
  }

  Stream<CollectionExecution?> listenToCollectionExecution({required String id}) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while listening to a collection execution');
    }

    return _db
        .listenToDocument(id: id, collectionPath: paths.userCollectionsExecutions(userId: currentUserId))
        .map((execution) => execution != null ? _collectionExecutionsSerializer.from(execution.data) : null)
        .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
  }

  Future<void> updateCollectionExecution({
    required String collectionId,
    required bool isPrivate,
    required List<MemoExecution> executions,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while listening to a collection execution');
    }

    final totalTimeSpent = executions.fold<int>(0, (value, execution) => value + execution.timeSpentInMillis);
    final updatedDifficulties = Map.fromEntries(MemoDifficulty.values.map((difficulty) =>
        MapEntry(difficulty, executions.where((execution) => difficulty == execution.markedDifficulty).length)));

    try {
      await _db.runInTransaction(() async {
        final collectionExecutionsPath = paths.userCollectionsExecutions(userId: currentUserId);
        final rawCollection = await _db.get(id: collectionId, collectionPath: collectionExecutionsPath);
        final currentCollection =
            rawCollection != null ? _collectionExecutionsSerializer.from(rawCollection.data) : null;

        // TODO(matuella): This is pretty much part of what the services should be doing, move there and adjust the logic properly.
        // The missing part is that when a new collection is executed, it must create all blank executions (memos) associated.
        final Future<void> collectionExecutionWrite;
        if (currentCollection == null) {
          final newExecutions = Map.fromEntries(
            executions.map(
              (execution) => MapEntry(
                execution.id,
                MemoExecutionRecallMetadata(
                  id: execution.id,
                  totalExecutions: 1,
                  lastExecution: execution.finished,
                  lastMarkedDifficulty: execution.markedDifficulty,
                ),
              ),
            ),
          );

          final newCollectionExecution = CollectionExecution(
            id: collectionId,
            executions: newExecutions,
            isPrivate: isPrivate,
            timeSpentInMillis: totalTimeSpent,
            difficulties: updatedDifficulties,
          );

          collectionExecutionWrite = _db.set(
            collectionPath: collectionExecutionsPath,
            id: collectionId,
            data: _collectionExecutionsSerializer.to(newCollectionExecution),
          );
        } else {
          final updatedMemosExecutions = currentCollection.executions.map((id, metadata) {
            final existingExecution = executions.firstWhereOrNull((execution) => execution.id == metadata.id);

            if (existingExecution != null) {
              return MapEntry(
                id,
                metadata.copyWith(
                  totalExecutions: metadata.totalExecutions + 1,
                  lastExecution: existingExecution.finished,
                  lastMarkedDifficulty: existingExecution.markedDifficulty,
                ),
              );
            }

            return MapEntry(id, metadata);
          });

          executions
              .where(
                (execution) => !currentCollection.executions.containsKey(execution.id),
              )
              .map(
                (newExecution) => MemoExecutionRecallMetadata(
                  id: newExecution.id,
                  totalExecutions: 1,
                  lastExecution: newExecution.finished,
                  lastMarkedDifficulty: newExecution.markedDifficulty,
                ),
              )
              .forEach(
                (metadata) => updatedMemosExecutions[metadata.id] = metadata,
              );

          collectionExecutionWrite = _db.set(
            collectionPath: collectionExecutionsPath,
            id: collectionId,
            data: <String, dynamic>{
              CollectionExecutionKeys.executionsDifficulty:
                  updatedDifficulties.map((key, value) => MapEntry(key.raw, value)),
              CollectionExecutionKeys.executions:
                  updatedMemosExecutions.map((key, value) => MapEntry(key, _memoRecallMetadataSerializer.to(value))),
              CollectionExecutionKeys.timeSpentInMillis: FieldValue.increment(totalTimeSpent),
            },
          );
        }

        final newMemosExecutions = executions.map(
          (execution) => _db.set(
            collectionPath: paths.userMemosExecutions(userId: currentUserId, collectionId: collectionId),
            data: _memoExecutionsSerializer.to(execution),
            id: execution.id,
          ),
        );

        final userExecutionMetadataUpdate = _db.update(
          collectionPath: paths.users,
          id: currentUserId,
          data: <String, dynamic>{
            // TODO: How to update this without fetching user?
            // UserKeys.executionsDifficulty: executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
            CollectionExecutionKeys.timeSpentInMillis: FieldValue.increment(totalTimeSpent),
          },
        );

        await Future.wait([
          collectionExecutionWrite,
          userExecutionMetadataUpdate,
          ...newMemosExecutions,
        ]);
      });
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }

  Future<CollectionExecution?> getCollectionExecutionById(String id) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw InconsistentStateError.repository('Missing required user while fetching the user collection execution');
    }

    try {
      final rawExecution =
          await _db.get(id: id, collectionPath: paths.userCollectionsExecutions(userId: currentUserId));
      return rawExecution != null ? _collectionExecutionsSerializer.from(rawExecution.data) : null;
    } on FirestoreDatabaseError catch (error) {
      throw HttpException.failedRequest(debugInfo: error.toString());
    }
  }
}
