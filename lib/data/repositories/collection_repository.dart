import 'dart:async';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection.dart';

/// Handles all domain-specific operations pertaining to one or multiple [Collection]
abstract class CollectionRepository {
  /// Retrieves a [Collection] with the [id] argument
  Future<Collection> getCollection({required String id});

  /// Retrieves all available [Collection] and keeps listening to any changes made to them
  Future<List<Stream<Collection>>> listenToAllCollections();

  /// Retrieves all available [Collection]
  Future<List<Collection>> getAllCollections();

  /// Updates a [Collection] (of [id]) with the execution-related arguments
  ///
  /// Any update made to these properties, will override the current value, so make sure to update with the latest
  /// corresponding values.
  ///
  /// Because an execution may not update the [uniqueExecutionsAmount], this value is optional.
  Future<void> updateExecution({
    required String id,
    required Map<MemoDifficulty, int> executionsAmounts,
    required int timeSpentInMillis,
    int? uniqueExecutionsAmount,
  });
}

final _collectionSerializer = CollectionSerializer();
final _collectionTransformer = StreamTransformer<Map<String, dynamic>, Collection>.fromHandlers(
  handleData: (rawCollection, sink) {
    sink.add(_collectionSerializer.from(rawCollection));
  },
);

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._db);

  final SembastDatabase _db;
  final _collectionStore = 'collections';

  @override
  Future<Collection> getCollection({required String id}) async {
    final rawCollection = await _db.get(id: id, store: _collectionStore);
    if (rawCollection == null) {
      throw InconsistentStateError.repository(
          'Missing required collection (of record "$id") in store "$_collectionStore"');
    }

    return _collectionSerializer.from(rawCollection);
  }

  @override
  Future<List<Collection>> getAllCollections() async {
    final rawCollections = await _db.getAll(store: _collectionStore);
    return rawCollections.map(_collectionSerializer.from).toList();
  }

  @override
  Future<List<Stream<Collection>>> listenToAllCollections() async {
    final rawCollections = await _db.getAll(store: _collectionStore);
    final collectionIds = rawCollections.map((rawCollection) => rawCollection[CollectionKeys.id] as String).toList();

    final listenFutures =
        collectionIds.map((collectionId) => _db.listenTo(id: collectionId, store: _collectionStore)).toList();
    final rawCollectionListeners = await Future.wait(listenFutures);

    return rawCollectionListeners
        .map((collectionStream) => collectionStream.transform(_collectionTransformer))
        .toList();
  }

  @override
  Future<void> updateExecution({
    required String id,
    required Map<MemoDifficulty, int> executionsAmounts,
    required int timeSpentInMillis,
    int? uniqueExecutionsAmount,
  }) =>
      _db.put(
        id: id,
        object: <String, dynamic>{
          CollectionKeys.executionsAmounts: executionsAmounts,
          CollectionKeys.timeSpentInMillis: timeSpentInMillis,
          if (uniqueExecutionsAmount != null) CollectionKeys.uniqueMemoExecutionsAmount: uniqueExecutionsAmount,
        },
        store: _collectionStore,
      );
}
