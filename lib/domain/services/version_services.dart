import 'package:collection/collection.dart';

import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/data/repositories/user_repository.dart';
import 'package:memo/data/repositories/version_repository.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

/// Handles all domain-specific operations pertaining to all versioning made in the application
abstract class VersionServices {
  /// Compare all file-based collections (`CollectionMemos`) and compare to the user's stored `Collection`
  ///
  /// This not only compares if each `Collection` metadata are in sync with all stored, but also each respective `Memo`
  /// associated to those `Collections` that were added, updated or removed.
  ///
  /// This updates handle three major cases:
  ///   1. Transforms the local `CollectionMemos` into a brand new stored `Collection` (and its `Memo`s), when
  /// non-existent;
  ///   2. Updates all properties `RawCollection` when there is an update to a pre-existing `Collection`, meaning that
  /// each `Memo` is also added, updated or removed; or
  ///   3. Finds out that a stored `Collection` doesn't exist anymore, although we've opted to ignore this case right
  /// now, as we don't want to create an unwanted behavior. This use-case will probably be addressed at some point in
  /// the future.
  Future<void> updateCollectionsIfNeeded();
}

class VersionServicesImpl implements VersionServices {
  VersionServicesImpl({
    required this.userRepo,
    required this.versionRepo,
    required this.collectionRepo,
    required this.memoRepo,
  });

  final UserRepository userRepo;
  final VersionRepository versionRepo;
  final CollectionRepository collectionRepo;
  final MemoRepository memoRepo;

  @override
  Future<void> updateCollectionsIfNeeded() async {
    final versions = await Future.wait([
      userRepo.getLastCollectionsVersions(),
      versionRepo.getLocalCollectionVersions(),
    ]);

    final oldVersions = versions[0] ?? {};
    final newVersions = versions[1]!;

    final updatedCollectionsIds = <String>[];
    // As the docs said, we are ignoring the missing collections that are present on old but not on new.
    // Ideally we should simply delete them, but this may cause a bad user-experience, so we still need to think about
    // that more carefully.
    // final deletedCollectionsIds = <String>[];

    // Runs through all expected collections and check if they should be created/updated given their version versus the
    // last stored version
    for (final collectionId in newVersions.keys) {
      final existingCollectionVersion = oldVersions[collectionId];
      final expectedVersion = newVersions[collectionId];

      if (existingCollectionVersion != expectedVersion) {
        updatedCollectionsIds.add(collectionId);
      }
    }

    // Not a single collection changed, we can safely return
    if (updatedCollectionsIds.isEmpty) {
      return;
    }

    // Retrieve all locally-stored `LocalCollection`
    final updatedLocalCollections = await collectionRepo.getCollectionMemosByIds(updatedCollectionsIds);

    // Retrieve all old memos that are associated with the updated collection ids
    final allAssociatedOldMemos = await memoRepo.getAllMemosByAnyCollectionId(collectionIds: updatedCollectionsIds);

    // Run all memo-related operations, more specifically adding, updating and removing.
    final addedOrUpdatedMemos = <Memo>[];
    final deletedMemosUniqueIds = <String>[];

    for (final localCollection in updatedLocalCollections) {
      // Maps all collections to a list of tuples containing the collection, its memos amount and executions (empty)
      final oldMemos = allAssociatedOldMemos.where((memo) => memo.collectionId == localCollection.id).toList();
      final newMemos = localCollection.memosMetadata;

      // Make sure that all local collections have the latest data about the executions
      final uniqueExecutedMemos = oldMemos.where((memo) => !memo.isPristine);
      // Update the localCollection with the latest executed memos
      localCollection.addToExecutionsAmount(uniqueExecutedMemos.length);

      // First we check if there are any memo with different question/answer contents to be updated or, if one don't
      // exists, to be added.
      for (final newMemo in newMemos) {
        final oldMemo = oldMemos.firstWhereOrNull((memo) => memo.uniqueId == newMemo.uniqueId);

        if (oldMemo != null) {
          if (!_compareSameMetadataContents(oldMemo, newMemo)) {
            final updatedMemo = oldMemo.copyWith(rawQuestion: newMemo.rawQuestion, rawAnswer: newMemo.rawAnswer);
            addedOrUpdatedMemos.add(updatedMemo);
          }
        } else {
          final addedMemo = Memo(
            collectionId: localCollection.id,
            uniqueId: newMemo.uniqueId,
            rawQuestion: newMemo.rawQuestion,
            rawAnswer: newMemo.rawAnswer,
          );

          addedOrUpdatedMemos.add(addedMemo);
        }
      }

      // Then we check if the old memos contains one that doesn't exist anymore, so we can delete it if so
      //
      // Careful here: we shouldn't delete the previous execution-related metadata, because the user in fact did execute
      // those - now deleted - memos. So, the only thing that is removed here is the Memo itself - both Collection and
      // all related MemoExecution should still exist, as to keep the execution history intact.
      for (final oldMemo in oldMemos) {
        final memoStillExists = newMemos.firstWhereOrNull((newMemo) => newMemo.uniqueId == oldMemo.uniqueId) != null;

        if (!memoStillExists) {
          // Subtract one memo if this old memo was already executed once
          if (!oldMemo.isPristine) {
            localCollection.addToExecutionsAmount(-1);
          }
          deletedMemosUniqueIds.add(oldMemo.uniqueId);
        }
      }
    }

    await Future.wait([
      if (addedOrUpdatedMemos.isNotEmpty) memoRepo.putMemos(addedOrUpdatedMemos, updatesOnlyCollectionMetadata: true),
      if (deletedMemosUniqueIds.isNotEmpty) memoRepo.removeMemosByIds(deletedMemosUniqueIds),
      // Always-updated dependencies
      collectionRepo.putCollectionsWithCollectionMemos(updatedLocalCollections),
      userRepo.updateCollectionsVersions(newVersions),
    ]);
  }

  /// Uses a [DeepCollectionEquality] to compare if both `MemoCollectionMetadata` have the same question/answer
  bool _compareSameMetadataContents(Memo memo, MemoCollectionMetadata metadata) {
    const equality = DeepCollectionEquality();
    return equality.equals(memo.rawQuestion, metadata.rawQuestion) &&
        equality.equals(memo.rawAnswer, metadata.rawAnswer);
  }
}
