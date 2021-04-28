import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/data/repositories/memo_repository.dart';
import 'package:memo/domain/isolated_services/memory_stability_services.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/transients/collection_status.dart';

/// Handles all domain-specific operations pertaining to one or multiple [Collection]
abstract class CollectionServices {
  /// Retrieves all available [CollectionStatus] and keeps listening to any changes made to them
  Future<List<Stream<CollectionStatus>>> listenToAllCollectionsStatus();

  /// Retrieves all available [Collection]
  Future<List<Collection>> getAllCollections();

  /// Retrieves the [Collection] (with [collectionId]) current memory stability
  ///
  /// This value ranges from `0` to `1`, meaning lesser the value, worse is the memory stability.
  ///
  /// If [Collection.isPristine], this will return `0`.
  Future<double> getCollectionMemoryStability({required String collectionId});
}

class CollectionServicesImpl implements CollectionServices {
  CollectionServicesImpl({required this.collectionRepo, required this.memoRepo, required this.memoryServices});

  final CollectionRepository collectionRepo;
  final MemoRepository memoRepo;

  final MemoryStabilityServices memoryServices;

  @override
  Future<List<Stream<CollectionStatus>>> listenToAllCollectionsStatus() async {
    final collectionsStream = await collectionRepo.listenToAllCollections();
    return collectionsStream
        .map(
          // Asynchronously transform the stream due to the async calculations
          (collectionStream) => collectionStream.asyncMap((collection) async {
            double? memoryStability;
            if (collection.isCompleted) {
              memoryStability = await _getMemosAverageMemoryStability(collectionId: collection.id);
            }

            return CollectionStatus(collection, memoryStability);
          }),
        )
        .toList();
  }

  @override
  Future<List<Collection>> getAllCollections() => collectionRepo.getAllCollections();

  @override
  Future<double> getCollectionMemoryStability({required String collectionId}) =>
      _getMemosAverageMemoryStability(collectionId: collectionId);

  Future<double> _getMemosAverageMemoryStability({required String collectionId}) async {
    final allCollectionMemos = await memoRepo.getAllMemos(collectionId: collectionId);

    var averageStability = 0.0;
    allCollectionMemos.forEach((memo) {
      final stability = memoryServices.evaluateMemoryRecall(memo);
      if (stability != null) {
        averageStability += stability;
      }
    });

    return averageStability / allCollectionMemos.length;
  }
}
