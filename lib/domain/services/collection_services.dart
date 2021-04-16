import 'package:memo/data/repositories/collection_repository.dart';
import 'package:memo/domain/models/collection.dart';

abstract class CollectionServices {
  Future<List<Collection>> getAllCollections();
}

class CollectionServicesImpl implements CollectionServices {
  CollectionServicesImpl(this.repo);

  final CollectionRepository repo;

  @override
  Future<List<Collection>> getAllCollections() => repo.getAllCollections();
}
