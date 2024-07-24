import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/application/view-models/app_vm.dart';
import 'package:memo/application/view-models/item_metadata.dart';
import 'package:memo/domain/enums/resource_type.dart';
import 'package:memo/domain/models/resource.dart';
import 'package:memo/domain/services/collection_services.dart';
import 'package:memo/domain/services/resource_services.dart';
import 'package:memo/domain/transients/collection_status.dart';

final collectionDetailsVM = StateNotifierProvider.family<CollectionDetailsVM, CollectionDetailsState, String>(
  (ref, collectionId) => CollectionDetailsVMImpl(
    collectionId: collectionId,
    collectionServices: ref.read(collectionServices),
    resourceServices: ref.read(resourceServices),
  ),
);

abstract class CollectionDetailsVM extends StateNotifier<CollectionDetailsState> {
  CollectionDetailsVM(CollectionDetailsState state) : super(state);
}

class CollectionDetailsVMImpl extends CollectionDetailsVM {
  CollectionDetailsVMImpl({
    required this.collectionId,
    required this.collectionServices,
    required this.resourceServices,
  }) : super(LoadingCollectionDetailsState()) {
    _loadCollection();
  }

  final String collectionId;
  final CollectionServices collectionServices;
  final ResourceServices resourceServices;

  List<Resource>? _associatedResources;
  late final StreamSubscription<CollectionStatus> _listener;

  Future<void> _loadCollection() async {
    final stream = await collectionServices.listenToCollectionStatus(collectionId: collectionId);

    _listener = stream.listen((collectionStatus) async {
      // Uses the collection tags to fetch all associated resources.
      final tags = collectionStatus.collection.tags;
      _associatedResources ??= await resourceServices.getResourcesWithAnyTags(tags);
      final mappedResources = _associatedResources!
          .map(
            (resource) => ResourceInfo(
              resource.type,
              description: resource.description,
              url: resource.url,
            ),
          )
          .toList();

      final contributors = collectionStatus.collection.contributors
          .map(
            (contributor) => ContributorInfo(
              name: contributor.name,
              imageUrl: contributor.imageUrl,
              url: contributor.url,
            ),
          )
          .toList();

      final description = collectionStatus.collection.description;
      final memosAmount = collectionStatus.collection.uniqueMemosAmount;

      state = LoadedCollectionDetailsState(
        metadata: mapStatusToMetadata(collectionStatus),
        description: description,
        memosAmount: memosAmount,
        resources: mappedResources,
        contributors: contributors,
      );
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }
}

abstract class CollectionDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadingCollectionDetailsState extends CollectionDetailsState {}

class LoadedCollectionDetailsState extends CollectionDetailsState {
  LoadedCollectionDetailsState({
    required this.metadata,
    required this.description,
    required this.memosAmount,
    required this.resources,
    required this.contributors,
  });

  final CollectionItem metadata;
  final String description;
  final int memosAmount;
  final List<ResourceInfo> resources;
  final List<ContributorInfo> contributors;
}

class ResourceInfo extends Equatable {
  const ResourceInfo(this.type, {required this.description, required this.url});

  final ResourceType type;
  final String description;
  final String url;

  @override
  List<Object?> get props => [type, description, url];
}

class ContributorInfo extends Equatable {
  const ContributorInfo({required this.name, required this.imageUrl, required this.url});

  final String name;
  final String? imageUrl;
  final String? url;

  @override
  List<Object?> get props => [name, imageUrl, url];
}
