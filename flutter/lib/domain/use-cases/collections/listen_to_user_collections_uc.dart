import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/data/repositories/user_collection_repository.dart';
import 'package:memo/domain/models/collection.dart';

abstract class ListenToUserCollectionsUC {
  CursorPaginatedResult<Collection> run({required String category});
}

class ListenToUserCollectionsUCImpl implements ListenToUserCollectionsUC {
  ListenToUserCollectionsUCImpl(this.collectionRepo);

  final UserCollectionRepositoryImpl collectionRepo;

  @override
  CursorPaginatedResult<Collection> run({required String category}) =>
      collectionRepo.listenToPaginatedUserCollections(pageSize: 10);
}
