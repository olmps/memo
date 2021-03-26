import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';

/// Handles the local persistence to the database
abstract class DatabaseRepository {
  /// Adds an [object] to the [store], using a [serializer]
  ///
  /// If there is already an object with the same [KeyStorable.id], the default behavior is to merge all of its fields.
  /// [shouldMerge] should be `false` if pre-existing fields should not be merged.
  Future<void> put<T extends KeyStorable>({
    required T object,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
    bool shouldMerge = true,
  });

  /// Deletes the value with [key] from the [store]
  Future<void> removeObject({required String key, required DatabaseStore store});

  /// Retrieves an object with [key] from the [store]
  ///
  /// Returns `null` if the key doesn't exist
  Future<T?> getObject<T extends KeyStorable>({
    required String key,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });

  /// Retrieves all objects within [store]
  Future<List<T>> getAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });

  /// Retrieves a stream of all the [store] objects, triggered whenever any update occurs to this [store]
  Future<Stream<List<T>>> listenAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  });
}

enum DatabaseStore {
  decks,
  cards,
  executions,
  resources,
}

/// Middleware that should be responsible of parsing a type [T] to/from a JSON representation
abstract class JsonSerializer<T extends Object> {
  T fromMap(Map<String, dynamic> json);
  Map<String, dynamic> mapOf(T object);
}

/// Base class that adds a key [id] to allow its implementation to be stored/identified in any database
abstract class KeyStorable extends Equatable {
  const KeyStorable({required this.id});
  final String id;
}

//
// DatabaseRepository implementation using `sembast`
//
class DatabaseRepositoryImpl implements DatabaseRepository {
  DatabaseRepositoryImpl(this._db);

  // `sembast` database instance
  final Database _db;

  @override
  Future<void> put<T extends KeyStorable>({
    required T object,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
    bool shouldMerge = true,
  }) async {
    final storeMap = stringMapStoreFactory.store(store.key);
    final deserializedObject = serializer.mapOf(object);

    await storeMap.record(object.id).put(_db, deserializedObject, merge: shouldMerge);
  }

  @override
  Future<void> removeObject({required String key, required DatabaseStore store}) async {
    final storeMap = stringMapStoreFactory.store(store.key);
    await storeMap.record(key).delete(_db);
  }

  @override
  Future<T?> getObject<T extends KeyStorable>({
    required String key,
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  }) async {
    final storeMap = stringMapStoreFactory.store(store.key);
    final rawObject = await storeMap.record(key).get(_db);

    if (rawObject != null) {
      return serializer.fromMap(rawObject);
    }

    return null;
  }

  @override
  Future<List<T>> getAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  }) async {
    final storeMap = stringMapStoreFactory.store(store.key);

    final allRecords = await storeMap.find(_db);

    return allRecords.map((record) => serializer.fromMap(record.value)).toList();
  }

  @override
  Future<Stream<List<T>>> listenAll<T extends KeyStorable>({
    required JsonSerializer<T> serializer,
    required DatabaseStore store,
  }) async {
    final storeMap = stringMapStoreFactory.store(store.key);

    final transformer = _snapshotSerializerTransformer(serializer);
    return storeMap.query().onSnapshots(_db).transform(transformer);
  }

  /// Transforms a list of `sembast` snapshot records into a list of objects parsed by [serializer]
  StreamTransformer<List<RecordSnapshot<String, Map<String, Object?>>>, List<T>>
      _snapshotSerializerTransformer<T extends Object>(JsonSerializer<T> serializer) {
    return StreamTransformer.fromHandlers(
      handleData: (snapshots, sink) {
        final transformedRecords = snapshots.map((record) => serializer.fromMap(record.value)).toList();
        sink.add(transformedRecords);
      },
    );
  }
}

extension StoreKeys on DatabaseStore {
  @visibleForTesting
  String get key {
    switch (this) {
      case DatabaseStore.decks:
        return 'decks';
      case DatabaseStore.cards:
        return 'cards';
      case DatabaseStore.executions:
        return 'card_executions';
      case DatabaseStore.resources:
        return 'resources';
    }
  }
}
