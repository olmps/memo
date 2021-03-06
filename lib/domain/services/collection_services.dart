import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/domain/isolated_services/memory_recall_services.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/transients/collection_status.dart';

/// Handles all domain-specific operations associated with [Collection]s.
abstract class CollectionServices {
  /// Streams all [CollectionStatus]es and emits a new event when any change occurs to any of them.
  Future<Stream<List<CollectionStatus>>> listenToAllCollectionsStatus();

  /// Retrieves a [Collection] (with [collectionId]) memory recall estimative.
  ///
  /// The returned value is the average of all [Collection]'s memos memory recall, ranging from `0` to `1`, meaning
  /// lesser the value, worse is the memory recall.
  ///
  /// If [Collection.isPristine], this will return `0`.
  Future<double> getCollectionMemoryRecall({required String collectionId});

  /// Retrieves a [Collection] of [id].
  Future<Collection> getCollectionById(String id);

  /// Streams a [CollectionStatus] - of [collectionId] - which emits a new event when any change occurs.
  Future<Stream<CollectionStatus>> listenToCollectionStatus({required String collectionId});
}

class CollectionServicesImpl implements CollectionServices {
  CollectionServicesImpl({required this.collectionRepo, required this.memoRepo, required this.memoryServices});

  final CollectionRepository collectionRepo;
  final MemoRepository memoRepo;

  final MemoryRecallServices memoryServices;

  @override
  Future<Stream<List<CollectionStatus>>> listenToAllCollectionsStatus() async {
    final collectionsStream = await collectionRepo.listenToAllCollections();
    // Asynchronously transform the stream due to the async calculations.
    return collectionsStream.asyncMap(
      (collections) {
        final mappedStatuses = collections.map(_mapCollectionToCollectionStatus).toList();
        return Future.wait(mappedStatuses);
      },
    );
  }

  @override
  Future<double> getCollectionMemoryRecall({required String collectionId}) =>
      _getMemosAverageMemoryRecall(collectionId: collectionId);

  Future<double> _getMemosAverageMemoryRecall({required String collectionId}) async {
    final allCollectionMemos = await memoRepo.getAllMemos(collectionId: collectionId);

    var averageRecall = 0.0;
    allCollectionMemos.forEach((memo) {
      final recall = memoryServices.evaluateMemoryRecall(memo);
      if (recall != null) {
        averageRecall += recall;
      }
    });

    return averageRecall / allCollectionMemos.length;
  }

  Future<CollectionStatus> _mapCollectionToCollectionStatus(Collection collection) async {
    double? memoryRecall;
    if (collection.isCompleted) {
      memoryRecall = await _getMemosAverageMemoryRecall(collectionId: collection.id);
    }

    return CollectionStatus(collection, memoryRecall);
  }

  @override
  Future<Collection> getCollectionById(String id) => collectionRepo.getCollection(id: id);

  @override
  Future<Stream<CollectionStatus>> listenToCollectionStatus({required String collectionId}) async {
    final collectionStream = await collectionRepo.listenToCollection(id: collectionId);

    return collectionStream.asyncMap((collection) {
      if (collection == null) {
        throw InconsistentStateError.service('Missing required collection (id "$collectionId")');
      }

      return _mapCollectionToCollectionStatus(collection);
    });
  }
}
