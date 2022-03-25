import 'dart:async';

import 'package:memo/core/faults/errors/inconsistent_state_error.dart';
import 'package:memo/data/gateways/application_bundle.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/collection_memos_serializer.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/data/serializers/contributor_serializer.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/transients/collection_memos.dart';

/// Handles all IO and serialization operations associated with [Collection]s.
abstract class CollectionRepository {
  /// Retrieves a [Collection] of [id].
  Future<Collection> getCollection({required String id});

  /// Streams all [Collection]s and emits a new event when any change occurs to any of them.
  Future<Stream<List<Collection>>> listenToAllCollections();

  /// Streams a [Collection] - of [id] - which emits a new event when any change occurs.
  Future<Stream<Collection?>> listenToCollection({required String id});

  /// Retrieves all [CollectionMemos].
  Future<List<CollectionMemos>> getAllCollectionMemos();

  /// Puts a list of [Collection] using a list of [collections] ([CollectionMemos]).
  ///
  /// Each [CollectionMemos] will match its respective [Collection] using the [CollectionMetadata.id] - if already
  /// existing, a new [Collection] will be added otherwise.
  Future<void> putCollectionsWithCollectionMemos(List<CollectionMemos> collections);

  /// Updates a [Collection] - of [id] - with execution-related arguments.
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
  final _contributorSerializer = ContributorSerializer();

  @override
  Future<Collection> getCollection({required String id}) async {
    final rawCollection = await _db.get(id: id, store: _collectionStore);
    if (rawCollection == null) {
      throw InconsistentStateError.repository(
        'Missing required collection (of record "$id") in store "$_collectionStore"',
      );
    }

    return _collectionSerializer.from(rawCollection);
  }

  @override
  Future<List<CollectionMemos>> getAllCollectionMemos() async {
    final collectionsPaths = await _appBundle.loadAssetsListPath(_collectionsRoot);
    final collectionsFutures = collectionsPaths.map(_appBundle.loadJson);
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
              CollectionKeys.contributors: collection.contributors.map(_contributorSerializer.to),
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
    return rawCollections.map((collections) => collections.map(_collectionSerializer.from).toList());
  }

  @override
  Future<Stream<Collection?>> listenToCollection({required String id}) async {
    final rawCollection = await _db.listenTo(id: id, store: _collectionStore);
    return rawCollection.map((collection) => collection != null ? _collectionSerializer.from(collection) : null);
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
