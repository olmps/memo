import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:meta/meta.dart';

final collectionsVM = StateNotifierProvider<CollectionsVM>((_) => CollectionsVMImpl());

enum CollectionsFilter { explore, review }
const availableFilters = CollectionsFilter.values;

abstract class CollectionsVM extends StateNotifier<CollectionsState> {
  CollectionsVM(CollectionsState state) : super(state);

  /// Updates the current [state] with [filter]
  Future<void> updateCollectionsFilter(CollectionsFilter filter);
}

const mockedCollections = [
  Collection(
    id: '1',
    name: 'Swift Fundamentals I',
    description: 'Swift fundamentals I description, bla bla bla.',
    category: 'Swift',
    tags: ['Linguagem de Programação'],
    timeSpentInMillis: 10000,
    memoryStability: 0.3,
  ),
  Collection(
    id: '2',
    name: 'Swift Fundamentals II',
    description: 'Swift fundamentals II description, bla bla bla.',
    category: 'Swift',
    tags: ['Linguagem de Programação'],
    timeSpentInMillis: 20000,
    memoryStability: 0.1,
  ),
  Collection(
    id: '3',
    name: 'Swift Fundamentals III',
    description: 'Swift fundamentals III description, bla bla bla.',
    category: 'Swift',
    tags: ['Linguagem de Programação'],
  ),
  Collection(
    id: '4',
    name: 'Git Fundamentals I',
    description: 'Git fundamentals I description, bla bla bla.',
    category: 'Git',
    tags: ['Controle de Versão', 'Linha de Comando'],
  ),
  Collection(
    id: '5',
    name: 'Git Fundamentals II',
    description: 'Git fundamentals II description, bla bla bla.',
    category: 'Git',
    tags: ['Controle de Versão', 'Linha de Comando'],
  ),
];

class CollectionsVMImpl extends CollectionsVM {
  CollectionsVMImpl() : super(LoadingCollectionsState(availableFilters.first)) {
    _loadCollections();
  }

  @override
  Future<void> updateCollectionsFilter(CollectionsFilter filter) async {
    state = LoadingCollectionsState(filter);

    // TODO(matuella): attach logic
    await Future.delayed(const Duration(seconds: 1), () {});

    final Map<String, List<Collection>> collectionsPerCategory;
    switch (filter) {
      case CollectionsFilter.explore:
        collectionsPerCategory = _mapCollectionsToCategories(mockedCollections);
        break;
      case CollectionsFilter.review:
        collectionsPerCategory =
            _mapCollectionsToCategories(mockedCollections.where((collection) => !collection.isPristine).toList());
        break;
    }

    state = LoadedCollectionsState(collectionsPerCategory, currentFilter: filter);
  }

  Future<void> _loadCollections() async {
    // TODO(matuella): attach logic
    await Future.delayed(const Duration(seconds: 1), () {});

    final collectionsPerCategory = _mapCollectionsToCategories(mockedCollections);
    state = LoadedCollectionsState(collectionsPerCategory, currentFilter: state.currentFilter);
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
  const CollectionsState(this.currentFilter);
  final CollectionsFilter currentFilter;
  int get filterIndex => availableFilters.indexOf(currentFilter);

  @override
  List<Object?> get props => [];
}

class LoadingCollectionsState extends CollectionsState {
  const LoadingCollectionsState(CollectionsFilter currentFilter) : super(currentFilter);
}

class LoadedCollectionsState extends CollectionsState {
  const LoadedCollectionsState(this._collectionsPerCategory, {required CollectionsFilter currentFilter})
      : super(currentFilter);

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
              memoryStability: collection.memoryStability,
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
  List<Object?> get props => [_collectionsPerCategory, currentFilter];
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
