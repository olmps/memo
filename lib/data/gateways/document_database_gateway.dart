import 'dart:async';
import 'package:sembast/sembast.dart';

/// Handles the local persistence to the database
abstract class DocumentDatabaseGateway {
  /// Adds an [object] to the [store], using a [id]
  ///
  /// If there is already an object with the same [id], the default behavior is to merge all of its fields.
  /// [shouldMerge] should be `false` if pre-existing fields should not be merged.
  Future<void> put({
    required String id,
    required Map<String, dynamic> object,
    required String store,
    bool shouldMerge = true,
  });

  /// Deletes the value with [id] from the [store]
  Future<void> remove({required String id, required String store});

  /// Retrieves an object with [id] from the [store]
  ///
  /// Returns `null` if the key doesn't exist
  Future<Map<String, dynamic>?> get({required String id, required String store});

  /// Retrieves all objects within [store]
  Future<List<Map<String, dynamic>>> getAll({required String store});

  /// Retrieves a stream of all the [store] objects, triggered whenever any update occurs to this [store]
  Future<Stream<List<Map<String, dynamic>>>> listenAll({required String store});
}

//
// DocumentDatabaseGateway implementation using `sembast`
//
class SembastGateway implements DocumentDatabaseGateway {
  SembastGateway(this._db);

  // `sembast` database instance
  final Database _db;

  @override
  Future<void> put({
    required String id,
    required Map<String, dynamic> object,
    required String store,
    bool shouldMerge = true,
  }) async {
    final storeMap = stringMapStoreFactory.store(store);

    await storeMap.record(id).put(_db, object, merge: shouldMerge);
  }

  @override
  Future<void> remove({required String id, required String store}) async {
    final storeMap = stringMapStoreFactory.store(store);
    await storeMap.record(id).delete(_db);
  }

  @override
  Future<Map<String, dynamic>?> get({required String id, required String store}) async {
    final storeMap = stringMapStoreFactory.store(store);
    return storeMap.record(id).get(_db);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({
    required String store,
  }) async {
    final storeMap = stringMapStoreFactory.store(store);

    final allRecords = await storeMap.find(_db);
    return allRecords.map((record) => record.value).toList();
  }

  @override
  Future<Stream<List<Map<String, dynamic>>>> listenAll({required String store}) async {
    final storeMap = stringMapStoreFactory.store(store);

    return storeMap.query().onSnapshots(_db).transform(snapshotTransformer);
  }

  /// Transforms a list of `sembast` snapshot records into a list of objects
  final snapshotTransformer =
      StreamTransformer<List<RecordSnapshot<String, Map<String, Object?>>>, List<Map<String, Object?>>>.fromHandlers(
    handleData: (snapshots, sink) {
      final transformedRecords = snapshots.map((record) => record.value).toList();
      sink.add(transformedRecords);
    },
  );
}
