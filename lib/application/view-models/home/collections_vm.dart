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
    _addCollectionsListeners();
  }

  final CollectionServices _services;

  StreamSubscription<List<CollectionStatus>>? _statusListener;
  List<CollectionItem> _cachedCollectionItems = [];

  @override
  Future<void> updateCollectionsSegment(CollectionsSegment segment) async {
    if (state is LoadingCollectionsState) {
      state = LoadingCollectionsState(segment);
      return;
    }

    _updateToLoadedStateWithCachedMetadata(segment: segment);
  }

  Future<void> _addCollectionsListeners() async {
    final statusesStream = await _services.listenToAllCollectionsStatus();
    _statusListener = statusesStream.listen((statuses) {
      _cachedCollectionItems = statuses.map(_mapStatusToMetadata).toList();
      _updateToLoadedStateWithCachedMetadata();
    });
  }

  CollectionItem _mapStatusToMetadata(CollectionStatus status) {
    final collection = status.collection;
    if (status.memoryRecall != null) {
      return CompletedCollectionItem(
        recallLevel: status.memoryRecall!,
        id: collection.id,
        name: collection.name,
        category: collection.category,
        tags: collection.tags,
      );
    } else {
      return IncompleteCollectionItem(
        executedUniqueMemos: collection.uniqueMemoExecutionsAmount,
        totalUniqueMemos: collection.uniqueMemosAmount,
        id: collection.id,
        name: collection.name,
        category: collection.category,
        tags: collection.tags,
      );
    }
  }

  /// Updates the [state] with [_cachedCollectionItems] filtered to a `CollectionsSegment`
  ///
  /// If [segment] is `null`, the current [state]'s segment is used ([CollectionsState.currentSegment]).
  void _updateToLoadedStateWithCachedMetadata({CollectionsSegment? segment}) {
    final normalizedSegment = segment ?? state.currentSegment;

    // Filters all the `CollectionItem` given the `segment`
    final filteredMetadata = _cachedCollectionItems.where((metadata) {
      switch (normalizedSegment) {
        case CollectionsSegment.explore:
          return metadata is IncompleteCollectionItem;
        case CollectionsSegment.review:
          return metadata is CompletedCollectionItem;
      }
    }).toList();

    final items = _mapMetadataToItems(filteredMetadata);
    state = LoadedCollectionsState(items, currentSegment: normalizedSegment);
  }

  /// Maps all [metadata] to its sorted [ItemMetadata] list
  ///
  /// To sort its contents, a `Map` is created to segment (meaning the key) its [metadata] in the same respective
  /// categories, and then flatten this `Map` entries into a single list, containing both keys and values, in a sorted
  /// fashion.
  List<ItemMetadata> _mapMetadataToItems(List<CollectionItem> metadata) {
    // It's a `LinkedHashMap` instance, so order is preserved.
    final metadataPerCategory = <String, List<CollectionItem>>{};
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
    _statusListener?.cancel();
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

abstract class CollectionItem extends ItemMetadata {
  CollectionItem({required this.id, required this.name, required this.category, required this.tags});

  final String id;
  final String name;
  final String category;
  final List<String> tags;

  @override
  List<Object?> get props => [id, name, category, tags];
}

/// Represents a Collection that have been fully executed - meaning, no pristine memos are left
class CompletedCollectionItem extends CollectionItem {
  CompletedCollectionItem({
    required this.recallLevel,
    required String id,
    required String name,
    required String category,
    required List<String> tags,
  }) : super(id: id, name: name, category: category, tags: tags);
  final double recallLevel;

  String get readableRecall => (recallLevel * 100).round().toString();

  @override
  List<Object?> get props => [...super.props, recallLevel];
}

/// Represents a Collection that hasn't been fully executed - meaning, there are still pristine memos left
class IncompleteCollectionItem extends CollectionItem {
  IncompleteCollectionItem({
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

  bool get isPristine => executedUniqueMemos == 0;

  String get readableCompletion => (completionPercentage * 100).round().toString();

  @override
  List<Object?> get props => [...super.props, executedUniqueMemos, totalUniqueMemos];
}
