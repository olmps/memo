import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/application/view-models/item_metadata.dart';
import 'package:memo/core/faults/exceptions/base_exception.dart';
import 'package:memo/domain/services/collection_purchase_services.dart';
import 'package:memo/domain/services/collection_services.dart';
import 'package:memo/domain/transients/collection_status.dart';
import 'package:meta/meta.dart';

final collectionsVM = StateNotifierProvider<CollectionsVM, CollectionsState>((ref) {
  return CollectionsVMImpl(ref.read(collectionServices), ref.read(collectionPurchaseServices));
});

/// Segment used to filter the current state of the [CollectionsVM].
enum CollectionsSegment { explore, review }

const availableSegments = CollectionsSegment.values;

abstract class CollectionsVM extends StateNotifier<CollectionsState> {
  CollectionsVM(CollectionsState state) : super(state);

  /// Updates the collections list when connected to the internet.
  Future<void> onRefresh();

  /// Updates the current [state] with [segment].
  ///
  /// Changing this [segment] also updates the displayed collections based on this [CollectionsSegment].
  Future<void> updateCollectionsSegment(CollectionsSegment segment);

  /// Purchase a deck, comparing its [id] and updating the isAvailable state to `true`.
  Future<void> purchaseCollection(String id);
}

class CollectionsVMImpl extends CollectionsVM {
  CollectionsVMImpl(this._services, this._purchaseServices) : super(LoadingCollectionsState(availableSegments.first)) {
    _addCollectionsListeners();
  }

  final CollectionServices _services;
  final CollectionPurchaseServices _purchaseServices;

  StreamSubscription<List<CollectionStatus>>? _statusListener;
  List<CollectionItem> _cachedCollectionItems = [];

  @override
  Future<void> onRefresh() async {
    await _addCollectionsListeners();
  }

  @override
  Future<void> purchaseCollection(String id) async {
    try {
      await _purchaseServices.purchaseCollection(id: id);
      state = PurchaseCollectionSuccess(state.currentSegment);
    } on BaseException catch (exception) {
      state = PurchaseCollectionFailed(exception, state.currentSegment);
    }
    _updateToLoadedStateWithCachedMetadata();
  }

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
      _cachedCollectionItems = statuses.map(mapStatusToMetadata).toList();
      _updateToLoadedStateWithCachedMetadata();
    });
  }

  /// Updates the [state] with [_cachedCollectionItems] filtered to a `CollectionsSegment`.
  ///
  /// If [segment] is `null`, the current [state] segment ([CollectionsState.currentSegment]) is used.
  void _updateToLoadedStateWithCachedMetadata({CollectionsSegment? segment}) {
    final normalizedSegment = segment ?? state.currentSegment;

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

  /// Maps all [metadata] to its sorted [ItemMetadata] list.
  ///
  /// To sort its contents, a `Map` is created to segment the [metadata] using the categories, and then flatten this
  /// `Map` into a single list, containing both keys and values.
  List<ItemMetadata> _mapMetadataToItems(List<CollectionItem> metadata) {
    // Default `Map` is a `LinkedHashMap`, order is preserved.
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

class PurchaseCollectionFailed extends CollectionsState {
  const PurchaseCollectionFailed(this.exception, CollectionsSegment currentSegment) : super(currentSegment);

  final BaseException exception;

  @override
  List<Object?> get props => [exception, ...super.props];
}

class PurchaseCollectionSuccess extends CollectionsState {
  const PurchaseCollectionSuccess(CollectionsSegment currentSegment) : super(currentSegment);
}
