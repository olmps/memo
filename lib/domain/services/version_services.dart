import 'package:collection/collection.dart';

import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/data/repositories/resource_repository.dart';
import 'package:memo/data/repositories/version_repository.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/models/resource.dart';

/// Handles all domain-specific operations associated with the application's versioning
abstract class VersionServices {
  /// Compares all file-based collections (`CollectionMemos`) to the user's database-stored collections (`Collection`).
  ///
  /// Updates not only the `Collections`, but also each respective `Memo` associated with them.
  ///
  /// The dependencies are updated when at least one of the criteria below is met:
  ///   - When there is a nonexistent `CollectionMemos` locally stored, requiring to transform these file-based
  /// `CollectionMemos` into a database-stored `Collection` (and all of their `Memo`s);
  ///   - When a `CollectionMemos` (and its `Memo`s) has any of its properties updated, in comparison to its local
  /// `Collection` counterpart, requiring all properties to be updated into these pre-existing `Collection`.
  ///
  // TODO(matuella): Define how to handle collection deletions:
  /// There is a third criteria that occurs when a stored `Collection` should be deleted, although it's being currently
  /// ignored, because we don't want to create an unwanted behavior. This use-case must be addressed at some point in
  /// the future.
  Future<void> updateDependenciesIfNeeded();
}

class VersionServicesImpl implements VersionServices {
  VersionServicesImpl({
    required this.versionRepo,
    required this.collectionRepo,
    required this.memoRepo,
    required this.resourceRepo,
  });

  final VersionRepository versionRepo;
  final CollectionRepository collectionRepo;
  final MemoRepository memoRepo;
  final ResourceRepository resourceRepo;

  @override
  Future<void> updateDependenciesIfNeeded() async {
    final versions = await Future.wait([
      versionRepo.getCurrentApplicationVersion(),
      versionRepo.getStoredApplicationVersion(),
    ]);

    final currentVersion = versions[0];
    final latestVersion = versions[1];

    if (currentVersion == latestVersion) {
      return;
    }

    final collectionsUpdates = await _updateCollections();
    final resourcesUpdates = await _updateResources();

    await Future.wait([
      ...collectionsUpdates,
      ...resourcesUpdates,
      versionRepo.updateToLatestApplicationVersion(),
    ]);
  }

  Future<List<Future>> _updateCollections() async {
    // Retrieve all locally-stored `LocalCollection`.
    final localCollections = await collectionRepo.getAllCollectionMemos();
    final localCollectionsIds = localCollections.map((collection) => collection.id).toList();

    // Retrieve all old memos that are associated with the updated collection ids.
    final allAssociatedOldMemos = await memoRepo.getAllMemosByAnyCollectionId(collectionIds: localCollectionsIds);

    // Run all memo-related operations, more specifically adding, updating and removing.
    final addedOrUpdatedMemos = <Memo>[];
    final deletedMemosUniqueIds = <String>[];

    for (final localCollection in localCollections) {
      // Maps all collections to a list of tuples containing the collection, its memos amount and executions (empty).
      final oldMemos = allAssociatedOldMemos.where((memo) => memo.collectionId == localCollection.id).toList();
      final newMemos = localCollection.memosMetadata;

      // Make sure that all local collections have the latest data about the executions.
      final uniqueExecutedMemos = oldMemos.where((memo) => !memo.isPristine);
      // Update the localCollection with the latest executed memos
      localCollection.addToExecutionsAmount(uniqueExecutedMemos.length);

      // First we check if there are any memo with different question/answer contents to be updated or, if one don't
      // exists, to be added.
      for (final newMemo in newMemos) {
        final oldMemo = oldMemos.firstWhereOrNull((memo) => memo.uniqueId == newMemo.uniqueId);

        if (oldMemo == null) {
          final addedMemo = Memo(
            collectionId: localCollection.id,
            uniqueId: newMemo.uniqueId,
            rawQuestion: newMemo.rawQuestion,
            rawAnswer: newMemo.rawAnswer,
          );

          addedOrUpdatedMemos.add(addedMemo);

          // We need to make sure if it exists, it still contains the same metadata contents, otherwise it must be
          // updated.
        } else if (!_compareSameMetadataContents(oldMemo, newMemo)) {
          final updatedMemo = oldMemo.copyWith(rawQuestion: newMemo.rawQuestion, rawAnswer: newMemo.rawAnswer);
          addedOrUpdatedMemos.add(updatedMemo);
        }
      }

      // Then we check if the old memos contains one that doesn't exist anymore, so we can delete it if so.
      //
      // Careful: we shouldn't delete the previous execution-related metadata, because the user in fact did execute
      // those - now deleted - memos. The only thing that is removed here is the Memo itself - both Collection and
      // all related MemoExecution should still exist, as to keep the execution history intact.
      for (final oldMemo in oldMemos) {
        final memoStillExists = newMemos.firstWhereOrNull((newMemo) => newMemo.uniqueId == oldMemo.uniqueId) != null;

        if (!memoStillExists) {
          // Subtract one memo if this old memo was already executed once.
          if (!oldMemo.isPristine) {
            localCollection.addToExecutionsAmount(-1);
          }

          deletedMemosUniqueIds.add(oldMemo.uniqueId);
        }
      }
    }

    return [
      if (addedOrUpdatedMemos.isNotEmpty) memoRepo.putMemos(addedOrUpdatedMemos, updatesOnlyCollectionMetadata: true),
      if (deletedMemosUniqueIds.isNotEmpty) memoRepo.removeMemosByIds(deletedMemosUniqueIds),
      collectionRepo.putCollectionsWithCollectionMemos(localCollections),
    ];
  }

  Future<List<Future>> _updateResources() async {
    // Retrieve all locally-stored resources.
    final localResources = await resourceRepo.getAllLocalResources();

    // Retrieve all resources.
    final oldResources = await resourceRepo.getAllResources();

    final addedOrUpdatedResources = <Resource>[];
    final deletedResourcesIds = <String>[];

    for (final localResource in localResources) {
      // Checking if there are any memo with different question/answer contents to be updated or, if one don't
      // exists, to be added.
      final oldResource = oldResources.firstWhereOrNull((resource) => resource.id == localResource.id);

      // We must update/add the following resource if it doesn't exist (null) or if it has any different property.
      if (oldResource == null || oldResource != localResource) {
        addedOrUpdatedResources.add(localResource);
      }
    }

    // Then we check if the old resources contains one that doesn't exist anymore, so we can delete it if so.
    for (final oldResource in oldResources) {
      final resourceStillExists = localResources.firstWhereOrNull((resource) => resource.id == oldResource.id) != null;

      if (!resourceStillExists) {
        deletedResourcesIds.add(oldResource.id);
      }
    }

    return [
      if (addedOrUpdatedResources.isNotEmpty) resourceRepo.putResources(addedOrUpdatedResources),
      if (deletedResourcesIds.isNotEmpty) resourceRepo.removeResourcesByIds(deletedResourcesIds),
    ];
  }

  /// Uses a [DeepCollectionEquality] to compare if both `MemoCollectionMetadata` have the same question/answer.
  bool _compareSameMetadataContents(Memo memo, MemoCollectionMetadata metadata) {
    const equality = DeepCollectionEquality();
    return equality.equals(memo.rawQuestion, metadata.rawQuestion) &&
        equality.equals(memo.rawAnswer, metadata.rawAnswer);
  }
}
