import 'package:equatable/equatable.dart';
import 'package:memo/domain/transients/collection_status.dart';
import 'package:meta/meta.dart';

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
  String get readableCompletion => (completionPercentage * 100).round().toString();

  bool get isPristine => executedUniqueMemos == 0;

  @override
  List<Object?> get props => [...super.props, executedUniqueMemos, totalUniqueMemos];
}

/// Uses the [CollectionStatus] properties to instantiate a corresponding [CollectionItem]
CollectionItem mapStatusToMetadata(CollectionStatus status) {
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
