import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/domain/models/collection.dart';

abstract class CollectionRepository {
  Future<List<Collection>> getAllCollections();
}

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._db);

  final _collectionSerializer = CollectionSerializer();
  final SembastDatabase _db;

  final _collectionStore = 'collections';

  @override
  Future<List<Collection>> getAllCollections() async {
    final rawCollections = await _db.getAll(store: _collectionStore);
    return rawCollections.map(_collectionSerializer.from).toList();
  }
}
