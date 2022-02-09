import 'dart:async';

import 'package:firestore_olmps/firestore_olmps.dart';
import 'package:memo/core/faults/exceptions/http_exception.dart';
import 'package:memo/data/repositories/paths.dart' as paths;
import 'package:memo/data/serializers/collection_serializer.dart';
import 'package:memo/domain/models/collection.dart';

class CollectionRepositoryImpl {
  CollectionRepositoryImpl(this._db);

  final FirestoreDatabase _db;

  final _collectionSerializer = CollectionSerializer();
  final _categorySerializer = CategorySerializer();

  CursorPaginatedResult<Category> listenToPaginatedCategories({required int pageSize}) {
    // TODO(matuella): add error interceptor to the `results` stream.
    // .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
    return _db.getAllPaginated(
      collectionPath: paths.collectionCategories,
      pageSize: pageSize,
      resultDeserializer: (doc) => _categorySerializer.from(doc.data),
      sorts: [QuerySort(field: CategoryKeys.name)],
      listenToChanges: true,
    );
  }

  CursorPaginatedResult<Collection> listenToPaginatedCollections({required int pageSize, String? category}) {
    // TODO(matuella): add error interceptor to the `results` stream.
    // .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
    return _db.getAllPaginated(
      collectionPath: paths.collections,
      pageSize: pageSize,
      resultDeserializer: (doc) => _collectionSerializer.from(doc.data),
      filters: [if (category != null) QueryFilter(field: CollectionKeys.category, isEqualTo: category)],
      listenToChanges: true,
    );
  }

  Stream<List<Collection>> listenToCollections({required int limit, String? category, String? locale}) => _db
      .listenTo(
        collectionPath: paths.collections,
        filters: [
          if (locale != null) QueryFilter(field: CollectionKeys.locale, isEqualTo: locale),
          if (category != null) QueryFilter(field: CollectionKeys.category, isEqualTo: category),
        ],
        limit: limit,
      )
      .map((collections) => collections.map((collection) => _collectionSerializer.from(collection.data)).toList())
      .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));

  Stream<Collection?> listenToCollection({required String id}) => _db
      .listenToDocument(id: id, collectionPath: paths.collections)
      .map((collection) => collection != null ? _collectionSerializer.from(collection.data) : null)
      .handleError((dynamic error) => throw HttpException.failedRequest(debugInfo: error.toString()));
}
