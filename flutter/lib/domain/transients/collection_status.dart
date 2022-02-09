import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/collection_execution.dart';

/// Groups a [Collection] with its memory recall.
class CollectionStatus {
  CollectionStatus(this.collection, [this.execution, this.memoryRecall])
      : assert(
          (execution?.isCompleted ?? false) ^ (memoryRecall == null),
          'When execution is completed, an associated memoryRecall is required',
        );

  final Collection collection;

  final CollectionExecution? execution;

  /// Average of all [execution]'s memos memory recall.
  ///
  /// Should be `null` if  [CollectionExecution.isCompleted] `false`.
  final double? memoryRecall;
}
