import 'package:equatable/equatable.dart';
import 'package:memo/domain/transients/collection_status.dart';
import 'package:meta/meta.dart';

/// Base class of metadata related to a `Collection`.
@immutable
abstract class ItemMetadata extends Equatable {}

class CollectionsCategoryMetadata extends ItemMetadata {
  CollectionsCategoryMetadata({required this.name});
  final String name;

  @override
  List<Object?> get props => [name];
}

abstract class CollectionItem extends ItemMetadata {
  CollectionItem({
    required this.id,
    required this.name,
    required this.category,
    required this.tags,
    required this.isAvailable,
  });

  final String id;
  final String name;
  final String category;
  final List<String> tags;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, name, category, tags, isAvailable];
}

/// Represents a collection that have been fully executed - where no pristine memos are left.
class CompletedCollectionItem extends CollectionItem {
  CompletedCollectionItem({
    required this.recallLevel,
    required String id,
    required String name,
    required String category,
    required List<String> tags,
    required bool isAvailable,
  }) : super(id: id, name: name, category: category, tags: tags, isAvailable: isAvailable);

  final double recallLevel;
  String get readableRecall => (recallLevel * 100).round().toString();

  @override
  List<Object?> get props => [...super.props, recallLevel];
}

/// Represents a collection that hasn't been fully executed - there are still pristine memos left.
class IncompleteCollectionItem extends CollectionItem {
  IncompleteCollectionItem({
    required this.executedUniqueMemos,
    required this.totalUniqueMemos,
    required String id,
    required String name,
    required String category,
    required List<String> tags,
    required bool isAvailable,
  }) : super(id: id, name: name, category: category, tags: tags, isAvailable: isAvailable);

  final int executedUniqueMemos;
  final int totalUniqueMemos;
  double get completionPercentage => executedUniqueMemos / totalUniqueMemos;
  String get readableCompletion => (completionPercentage * 100).round().toString();

  bool get isPristine => executedUniqueMemos == 0;

  @override
  List<Object?> get props => [...super.props, executedUniqueMemos, totalUniqueMemos];
}

/// Uses the [CollectionStatus] properties to instantiate a corresponding [CollectionItem].
CollectionItem mapStatusToMetadata(CollectionStatus status) {
  final collection = status.collection;
  if (status.memoryRecall != null) {
    return CompletedCollectionItem(
      recallLevel: status.memoryRecall!,
      id: collection.id,
      name: collection.name,
      category: collection.category,
      tags: collection.tags,
      isAvailable: collection.isAvailable,
    );
  } else {
    return IncompleteCollectionItem(
      executedUniqueMemos: collection.uniqueMemoExecutionsAmount,
      totalUniqueMemos: collection.uniqueMemosAmount,
      id: collection.id,
      name: collection.name,
      category: collection.category,
      tags: collection.tags,
      isAvailable: collection.isAvailable,
    );
  }
}
