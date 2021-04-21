import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:meta/meta.dart';

final collectionsVM = StateNotifierProvider<CollectionsVM>((_) => CollectionsVMImpl());

/// Segment used to filter the current state of the [CollectionsVM]
enum CollectionsSegment { explore, review }
const availableSegments = CollectionsSegment.values;

abstract class CollectionsVM extends StateNotifier<CollectionsState> {
  CollectionsVM(CollectionsState state) : super(state);

  /// Updates the current [state] with [segment]
  Future<void> updateCollectionsSegment(CollectionsSegment segment);
}

final mockedCollections = [
  Collection(
    id: '1',
    name: 'Swift Fundamentals I',
    description: 'Swift fundamentals I description, bla bla bla.',
    category: 'Swift',
    tags: const ['Linguagem de Programação'],
    timeSpentInMillis: 10000,
    uniqueMemosAmount: 1,
  ),
  Collection(
    id: '2',
    name: 'Swift Fundamentals II',
    description: 'Swift fundamentals II description, bla bla bla.',
    category: 'Swift',
    tags: const ['Linguagem de Programação'],
    timeSpentInMillis: 20000,
    uniqueMemosAmount: 1,
  ),
  Collection(
    id: '3',
    name: 'Swift Fundamentals III',
    description: 'Swift fundamentals III description, bla bla bla.',
    category: 'Swift',
    tags: const ['Linguagem de Programação'],
    uniqueMemosAmount: 1,
  ),
  Collection(
    id: '4',
    name: 'Git Fundamentals I',
    description: 'Git fundamentals I description, bla bla bla.',
    category: 'Git',
    tags: const ['Controle de Versão', 'Linha de Comando'],
    uniqueMemosAmount: 1,
  ),
  Collection(
    id: '5',
    name: 'Git Fundamentals II',
    description: 'Git fundamentals II description, bla bla bla.',
    category: 'Git',
    tags: const ['Controle de Versão', 'Linha de Comando'],
    uniqueMemosAmount: 1,
  ),
];

class CollectionsVMImpl extends CollectionsVM {
  CollectionsVMImpl() : super(LoadingCollectionsState(availableSegments.first)) {
    _loadCollections();
  }

  @override
  Future<void> updateCollectionsSegment(CollectionsSegment segment) async {
    state = LoadingCollectionsState(segment);

    // TODO(matuella): attach logic
    await Future.delayed(const Duration(seconds: 1), () {});

    final Map<String, List<Collection>> collectionsPerCategory;
    switch (segment) {
      case CollectionsSegment.explore:
        collectionsPerCategory = _mapCollectionsToCategories(mockedCollections);
        break;
      case CollectionsSegment.review:
        collectionsPerCategory =
            _mapCollectionsToCategories(mockedCollections.where((collection) => !collection.isPristine).toList());
        break;
    }

    state = LoadedCollectionsState(collectionsPerCategory, currentSegment: segment);
  }

  Future<void> _loadCollections() async {
    // TODO(matuella): attach logic
    await Future.delayed(const Duration(seconds: 1), () {});

    final collectionsPerCategory = _mapCollectionsToCategories(mockedCollections);
    state = LoadedCollectionsState(collectionsPerCategory, currentSegment: state.currentSegment);
  }

  Map<String, List<Collection>> _mapCollectionsToCategories(List<Collection> collections) {
    // It's a `LinkedHashMap` instance, so order is preserved.
    final collectionsPerCategory = <String, List<Collection>>{};
    collections.forEach((collection) {
      final category = collection.category;

      if (collectionsPerCategory.containsKey(collection.category)) {
        final collectionsForKey = collectionsPerCategory[category]!..add(collection);

        collectionsPerCategory[category] = collectionsForKey;
      } else {
        collectionsPerCategory[category] = [collection];
      }
    });

    return collectionsPerCategory;
  }
}

@immutable
abstract class CollectionsState extends Equatable {
  const CollectionsState(this.currentSegment);
  final CollectionsSegment currentSegment;
  int get segmentIndex => availableSegments.indexOf(currentSegment);

  @override
  List<Object?> get props => [];
}

class LoadingCollectionsState extends CollectionsState {
  const LoadingCollectionsState(CollectionsSegment currentSegment) : super(currentSegment);
}

class LoadedCollectionsState extends CollectionsState {
  const LoadedCollectionsState(this._collectionsPerCategory, {required CollectionsSegment currentSegment})
      : super(currentSegment);

  final Map<String, List<Collection>> _collectionsPerCategory;

  List<CollectionItemMetadata> get collectionItems {
    final items = <CollectionItemMetadata>[];

    _collectionsPerCategory.entries.forEach((entry) {
      final collectionsMetadata = entry.value
          .map(
            (collection) => CollectionMetadata(
              id: collection.id,
              tags: collection.tags,
              name: collection.name,
              // TODO(matuella): Remove this placeholder and add logic when memoryStability calc is ready
              memoryStability: 0.5,
            ),
          )
          .toList();

      items
        ..add(CollectionsCategoryMetadata(name: entry.key))
        ..addAll(collectionsMetadata);
    });

    return items;
  }

  @override
  List<Object?> get props => [_collectionsPerCategory, currentSegment];
}

abstract class CollectionItemMetadata {}

class CollectionsCategoryMetadata extends CollectionItemMetadata {
  CollectionsCategoryMetadata({required this.name});
  final String name;
}

class CollectionMetadata extends CollectionItemMetadata {
  CollectionMetadata({required this.id, required this.tags, required this.name, this.memoryStability});
  final String id;
  final String name;
  final List<String> tags;
  final double? memoryStability;
}
