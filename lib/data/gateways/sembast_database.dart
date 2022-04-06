import 'dart:async';
import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/database_transaction_handler.dart';
import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart' as sembast;

export 'package:sembast/sembast.dart' show Finder, Filter;

/// Sembast implementation for an atomic database transaction.
///
/// Currently, there is no support for multiple transactions running simultaneously. If necessary, run a transaction
/// once, then run another after completing the first one.
///
/// Throws an [InconsistentStateError] if multiple transactions are ran in parallel.
abstract class SembastTransactionHandler implements DatabaseTransactionHandler {
  SembastTransactionHandler(this.db);

  @protected
  final sembast.Database db;

  @protected
  sembast.Transaction? currentTransaction;

  @override
  Future<void> runInTransaction(Future<void> Function() run) async {
    if (currentTransaction != null) {
      throw InconsistentStateError.gateway('Trying to run a new transaction while there is one already running');
    }

    try {
      await db.transaction((transaction) async {
        currentTransaction = transaction;
        await run();
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stack) {
      throw InconsistentStateError.gateway(
        'Failed transaction with Error:\n${error.toString()} \nStackTrace:\n${stack.toString()}',
      );
    } finally {
      currentTransaction = null;
    }
  }
}

/// Handles the local persistence to the database.
abstract class SembastDatabase extends SembastTransactionHandler {
  SembastDatabase(sembast.Database db) : super(db);

  /// Adds an [object] to the [store], using an [id].
  ///
  /// If there is already an object with the same [id], the default behavior is to merge all of its fields.
  ///
  /// [shouldMerge] should be `false` if pre-existing fields should not be merged.
  Future<void> put({
    required String id,
    required Map<String, dynamic> object,
    required String store,
    bool shouldMerge = true,
  });

  /// Adds a list of [objects] to the [store], using their respective [ids].
  ///
  /// If there is already one or more objects with the same [ids], defaults to merging all of its fields.
  ///
  /// [shouldMerge] should be `false` if pre-existing fields should not be merged.
  Future<void> putAll({
    required List<String> ids,
    required List<Map<String, dynamic>> objects,
    required String store,
    bool shouldMerge = true,
  });

  /// Deletes the value with [id] from the [store].
  Future<void> remove({required String id, required String store});

  /// Deletes all objects with the following [ids] from the [store].
  Future<void> removeAll({required List<String> ids, required String store});

  /// Retrieves an object with [id] from the [store].
  ///
  /// Returns `null` if the key doesn't exist.
  Future<Map<String, dynamic>?> get({required String id, required String store});

  /// Retrieves all objects within [store].
  Future<List<Map<String, dynamic>>> getAll({required String store, sembast.Finder? finder});

  /// Retrieves all objects with the following [ids] from the [store].
  Future<List<Map<String, dynamic>?>> getAllByIds({required List<String> ids, required String store});

  /// Retrieves a stream of all the [store] objects, triggered whenever any update occurs to this [store].
  Future<Stream<List<Map<String, dynamic>>>> listenAll({required String store});

  /// Retrieves a stream of a single [store] object, triggered whenever any update occurs to this object's [id].
  Future<Stream<Map<String, dynamic>?>> listenTo({required String id, required String store});
}

class SembastDatabaseImpl extends SembastDatabase {
  SembastDatabaseImpl(sembast.Database db) : super(db);

  @override
  Future<void> put({
    required String id,
    required Map<String, dynamic> object,
    required String store,
    bool shouldMerge = true,
  }) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    await storeMap.record(id).put(currentTransaction ?? db, object, merge: shouldMerge);
  }

  @override
  Future<void> putAll({
    required List<String> ids,
    required List<Map<String, dynamic>> objects,
    required String store,
    bool shouldMerge = true,
  }) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    await storeMap.records(ids).put(currentTransaction ?? db, objects, merge: shouldMerge);
  }

  @override
  Future<void> remove({required String id, required String store}) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    await storeMap.record(id).delete(currentTransaction ?? db);
  }

  @override
  Future<void> removeAll({required List<String> ids, required String store}) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    await storeMap.records(ids).delete(currentTransaction ?? db);
  }

  @override
  Future<Map<String, dynamic>?> get({required String id, required String store}) {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    return storeMap.record(id).get(currentTransaction ?? db);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({required String store, sembast.Finder? finder}) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);

    final allRecords = await storeMap.find(currentTransaction ?? db, finder: finder);
    return allRecords.map((record) => record.value).toList();
  }

  @override
  Future<List<Map<String, dynamic>?>> getAllByIds({required List<String> ids, required String store}) {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    return storeMap.records(ids).get(currentTransaction ?? db);
  }

  @override
  Future<Stream<List<Map<String, dynamic>>>> listenAll({required String store}) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    // Maps a list of `sembast` snapshot records into a list of objects.
    return storeMap.query().onSnapshots(db).map((snapshots) => snapshots.map((record) => record.value).toList());
  }

  @override
  Future<Stream<Map<String, dynamic>?>> listenTo({required String id, required String store}) async {
    final storeMap = sembast.stringMapStoreFactory.store(store);
    // Maps a single `sembast` snapshot record into an object.
    return storeMap.record(id).onSnapshot(db).map((snapshot) => snapshot?.value);
  }
}
