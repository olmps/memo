import 'package:memo/domain/models/collection.dart';

/// Groups a [Collection] with its memory recall.
class CollectionStatus {
  CollectionStatus(this.collection, this.memoryRecall, {required this.isVisible});

  final Collection collection;

  /// Average of all [collection]'s memos memory recall.
  ///
  /// Should be `null` if [Collection.isCompleted] is `false`.
  final double? memoryRecall;

  final bool isVisible;
}
