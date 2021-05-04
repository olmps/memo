import 'dart:async';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/application_bundle.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/data/serializers/collection_memos_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/transients/collection_memos.dart';

/// Handles all read, write and serialization operations pertaining to one or multiple [Collection]
abstract class CollectionRepository {
  /// Retrieves a [Collection] with the [id] argument
  Future<Collection> getCollection({required String id});

  /// Retrieves all available [Collection] and keeps listening to any changes made to them
  Future<Stream<List<Collection>>> listenToAllCollections();

  /// Retrieves all available [Collection]
  Future<List<Collection>> getAllCollections();

  /// Retrieves all [CollectionMemos], matched by the respective ([ids])
  Future<List<CollectionMemos>> getCollectionMemosByIds(List<String> ids);

  /// Put all [Collection] with a list of [CollectionMemos]
  ///
  /// All [collections] match their respective [Collection] using the [CollectionMetadata.id] - if already existing
  Future<void> putCollectionsWithCollectionMemos(List<CollectionMemos> collections);

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

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._db, this._appBundle);

  final SembastDatabase _db;
  final _collectionStore = 'collections';

  final ApplicationBundle _appBundle;
  final _collectionsRoot = 'assets/collections';
  final _collectionsMemosSerializer = CollectionMemosSerializer();

  final _collectionSerializer = CollectionSerializer();

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
  Future<List<CollectionMemos>> getCollectionMemosByIds(List<String> ids) async {
    final collectionsFutures = ids.map((id) => _appBundle.loadJson('$_collectionsRoot/$id.json'));
    final rawCollections = await Future.wait<dynamic>(collectionsFutures);

    final castCollections = List<Map<String, dynamic>>.from(rawCollections);
    return castCollections.map(_collectionsMemosSerializer.from).toList();
  }

  @override
  Future<void> putCollectionsWithCollectionMemos(List<CollectionMemos> collections) async {
    return _db.putAll(
      ids: collections.map((collection) => collection.id).toList(),
      objects: collections
          .map(
            (collection) => {
              CollectionKeys.id: collection.id,
              CollectionKeys.name: collection.name,
              CollectionKeys.description: collection.description,
              CollectionKeys.category: collection.category,
              CollectionKeys.tags: collection.tags,
              CollectionKeys.uniqueMemosAmount: collection.uniqueMemosAmount,
              CollectionKeys.uniqueMemoExecutionsAmount: collection.uniqueMemoExecutionsAmount,
            },
          )
          .toList(),
      store: _collectionStore,
    );
  }

  @override
  Future<Stream<List<Collection>>> listenToAllCollections() async {
    final rawCollections = await _db.listenAll(store: _collectionStore);
    return rawCollections.map((event) => event.map(_collectionSerializer.from).toList());
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
          CollectionKeys.executionsAmounts: executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
          CollectionKeys.timeSpentInMillis: timeSpentInMillis,
          if (uniqueExecutionsAmount != null) CollectionKeys.uniqueMemoExecutionsAmount: uniqueExecutionsAmount,
        },
        store: _collectionStore,
      );
}
