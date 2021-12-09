import 'dart:async';

import 'package:memo/data/gateways/application_bundle.dart';
import 'package:memo/data/gateways/sembast_database.dart';
import 'package:memo/data/serializers/resource_serializer.dart';
import 'package:memo/domain/models/resource.dart';

/// Handles all IO and serialization operations associated with [Resource]s.
abstract class ResourceRepository {
  /// Puts a list of [resources].
  ///
  /// If a [Resource] with [Resource.id] already exists, it will be overridden.
  Future<void> putResources(List<Resource> resources);

  /// Retrieves all database-stored [Resource]s.
  ///
  /// The optional [associatedTags] filters all resources that contain **at least** one of the tags.
  ///
  /// I.e.:
  /// A [Resource.tags] of value `['tag 1', 'tag 2']`, will be returned when calling:
  /// `getAllResources(associatedTags: ['tag 1']);`.
  Future<List<Resource>> getAllResources({List<String>? associatedTags});

  /// Removes a list of resources by their respective [ids].
  Future<void> removeResourcesByIds(List<String> ids);

  /// Retrieves all file-stored [Resource]s.
  Future<List<Resource>> getAllLocalResources();
}

class ResourceRepositoryImpl implements ResourceRepository {
  ResourceRepositoryImpl(this._db, this._appBundle);

  final SembastDatabase _db;
  final _resourcesStore = 'resources';

  final ApplicationBundle _appBundle;
  final _resourcesPath = 'assets/resources.json';

  final _resourceSerializer = ResourceSerializer();

  @override
  Future<void> putResources(List<Resource> resources) => _db.putAll(
        ids: resources.map((resource) => resource.id).toList(),
        objects: resources.map(_resourceSerializer.to).toList(),
        store: _resourcesStore,
      );

  @override
  Future<List<Resource>> getAllResources({List<String>? associatedTags}) async {
    Filter? filter;
    if (associatedTags != null) {
      final tagsFilters = associatedTags.map((tag) => Filter.equals(ResourceKeys.tags, tag, anyInList: true)).toList();
      filter = Filter.or(tagsFilters);
    }

    final finder = Finder(filter: filter);
    final rawResources = await _db.getAll(store: _resourcesStore, finder: finder);
    return rawResources.map(_resourceSerializer.from).toList();
  }

  @override
  Future<void> removeResourcesByIds(List<String> ids) => _db.removeAll(ids: ids, store: _resourcesStore);

  @override
  Future<List<Resource>> getAllLocalResources() async {
    final dynamic rawResources = await _appBundle.loadJson(_resourcesPath);
    final parsedResources = List<Map<String, dynamic>>.from(rawResources as List);
    return parsedResources.map(_resourceSerializer.from).toList();
  }
}
