import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/domain/services/collection_services.dart';
import 'package:memo/domain/transients/collection_status.dart';
import 'package:meta/meta.dart';

final collectionsVM = StateNotifierProvider<CollectionsVM>((ref) {
  return CollectionsVMImpl(ref.read(collectionServices));
});

/// Segment used to filter the current state of the [CollectionsVM]
enum CollectionsSegment { explore, review }
const availableSegments = CollectionsSegment.values;

abstract class CollectionsVM extends StateNotifier<CollectionsState> {
  CollectionsVM(CollectionsState state) : super(state);

  /// Updates the current [state] with [segment]
  ///
  /// Changing the current state's [segment] implies that the displayed collections should be filtered to match the
  /// respective conditions for this specific [CollectionsSegment].
  Future<void> updateCollectionsSegment(CollectionsSegment segment);
}

class CollectionsVMImpl extends CollectionsVM {
  CollectionsVMImpl(this._services) : super(LoadingCollectionsState(availableSegments.first)) {
    _loadInitialCollections();
  }

  final CollectionServices _services;
  List<StreamSubscription<CollectionStatus>>? _statusListeners;

  final _cachedCollectionMetadata = <CollectionMetadata>[];

  @override
  Future<void> updateCollectionsSegment(CollectionsSegment segment) async {
    if (state is LoadingCollectionsState) {
      state = LoadingCollectionsState(segment);
      return;
    }

    // Filters all the `CollectionMetadata` given the `segment`
    final filteredMetadata = _cachedCollectionMetadata.where((metadata) {
      switch (segment) {
        case CollectionsSegment.explore:
          return metadata is CompletedCollectionMetadata;
        case CollectionsSegment.review:
          return metadata is IncompleteCollectionMetadata;
      }
    }).toList();

    final items = _mapMetadataToItems(filteredMetadata);
    state = LoadedCollectionsState(items, currentSegment: segment);
  }

  Future<void> _loadInitialCollections() async {
    final collections = await _services.getAllCollectionsStatus();
    _cachedCollectionMetadata.addAll(collections.map(_mapStatusToMetadata));
    return _addCollectionsListeners();
  }

  Future<void> _addCollectionsListeners() async {
    final statusStreams = await _services.listenToAllCollectionsStatus();
    // Listens to each individual stream, as we don't want to update all the objects once a single one changes
    _statusListeners = statusStreams.map((statusStream) {
      var isFirstUpdate = true;
      return statusStream.listen((status) {
        final cachedIndex = _cachedCollectionMetadata.indexWhere((metadata) => status.collection.id == metadata.id);
        // TODO(matuella): TEST IF THIS IS NEEDED
        if (!isFirstUpdate) {
          _cachedCollectionMetadata[cachedIndex] = _mapStatusToMetadata(status);
          // Force an update
          updateCollectionsSegment(state.currentSegment);
        } else {
          isFirstUpdate = false;
        }
      });
    }).toList();
  }

  CollectionMetadata _mapStatusToMetadata(CollectionStatus status) {
    final collection = status.collection;
    if (status.memoryStability != null) {
      return CompletedCollectionMetadata(
        memoryStability: status.memoryStability!,
        id: collection.id,
        name: collection.name,
        category: collection.category,
        tags: collection.tags,
      );
    } else {
      return IncompleteCollectionMetadata(
        executedUniqueMemos: collection.uniqueMemoExecutionsAmount,
        totalUniqueMemos: collection.uniqueMemosAmount,
        id: collection.id,
        name: collection.name,
        category: collection.category,
        tags: collection.tags,
      );
    }
  }

  /// Maps all [metadata] to its sorted [ItemMetadata] list
  ///
  /// To sort its contents, a `Map` is created to segment (meaning the key) its [metadata] in the same respective
  /// categories, and then flatten this `Map` entries into a single list, containing both keys and values, in a sorted
  /// fashion.
  List<ItemMetadata> _mapMetadataToItems(List<CollectionMetadata> metadata) {
    // It's a `LinkedHashMap` instance, so order is preserved.
    final metadataPerCategory = <String, List<CollectionMetadata>>{};
    metadata.forEach((metadata) {
      final category = metadata.category;

      if (metadataPerCategory.containsKey(category)) {
        final collectionsForKey = metadataPerCategory[category]!..add(metadata);

        metadataPerCategory[category] = collectionsForKey;
      } else {
        metadataPerCategory[category] = [metadata];
      }
    });

    final items = <ItemMetadata>[];

    metadataPerCategory.entries.forEach((entry) {
      items
        ..add(CollectionsCategoryMetadata(name: entry.key))
        ..addAll(entry.value);
    });

    return items;
  }

  @override
  void dispose() {
    _statusListeners?.forEach((listener) => listener.cancel());
    super.dispose();
  }
}

@immutable
abstract class CollectionsState extends Equatable {
  const CollectionsState(this.currentSegment);
  final CollectionsSegment currentSegment;
  int get segmentIndex => availableSegments.indexOf(currentSegment);

  @override
  List<Object?> get props => [currentSegment];
}

class LoadingCollectionsState extends CollectionsState {
  const LoadingCollectionsState(CollectionsSegment currentSegment) : super(currentSegment);
}

class LoadedCollectionsState extends CollectionsState {
  const LoadedCollectionsState(this.collectionItems, {required CollectionsSegment currentSegment})
      : super(currentSegment);

  final List<ItemMetadata> collectionItems;

  @override
  List<Object?> get props => [collectionItems, ...super.props];
}

/// Base class to be implemented to any metadata related to a `Collection`
///
/// The purpose of this class and its subclasses are only to make the UI work easier and more agnostic to any possible
/// logic, being responsible solely for rendering the layout given each metadata.
@immutable
abstract class ItemMetadata extends Equatable {}

class CollectionsCategoryMetadata extends ItemMetadata {
  CollectionsCategoryMetadata({required this.name});
  final String name;

  @override
  List<Object?> get props => [name];
}

abstract class CollectionMetadata extends ItemMetadata {
  CollectionMetadata({
    required this.id,
    required this.name,
    required this.category,
    required this.tags,
  });

  final String id;
  final String name;
  final String category;
  final List<String> tags;

  @override
  List<Object?> get props => [id, name, category, tags];
}

/// Represents a Collection that have been fully executed - meaning, no pristine memos are left
class CompletedCollectionMetadata extends CollectionMetadata {
  CompletedCollectionMetadata({
    required this.memoryStability,
    required String id,
    required String name,
    required String category,
    required List<String> tags,
  }) : super(id: id, name: name, category: category, tags: tags);
  final double memoryStability;

  @override
  List<Object?> get props => [...super.props, memoryStability];
}

/// Represents a Collection that hasn't been fully executed - meaning, there are still pristine memos left
class IncompleteCollectionMetadata extends CollectionMetadata {
  IncompleteCollectionMetadata({
    required this.executedUniqueMemos,
    required this.totalUniqueMemos,
    required String id,
    required String name,
    required String category,
    required List<String> tags,
  }) : super(id: id, name: name, category: category, tags: tags);

  final int executedUniqueMemos;
  final int totalUniqueMemos;
  double get completionPercentage => executedUniqueMemos / totalUniqueMemos;

  @override
  List<Object?> get props => [...super.props, executedUniqueMemos, totalUniqueMemos];
}
