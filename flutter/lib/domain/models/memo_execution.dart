import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:meta/meta.dart';

/// Immutable history of a `Memo` execution.
@immutable
class MemoExecution extends MemoCollectionMetadata {
  MemoExecution({
    required this.collectionId,
    required this.started,
    required this.finished,
    required String uniqueId,
    required List<Map<String, dynamic>> rawQuestion,
    required List<Map<String, dynamic>> rawAnswer,
    required this.markedDifficulty,
  })  : assert(started.isBefore(finished)),
        super(uniqueId: uniqueId, rawQuestion: rawQuestion, rawAnswer: rawAnswer);

  /// Parent collection's id.
  final String collectionId;

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => finished.difference(started).inMilliseconds;

  final MemoDifficulty markedDifficulty;

  @override
  List<Object?> get props => [
        collectionId,
        started,
        finished,
        markedDifficulty,
        uniqueId,
        rawQuestion,
        rawAnswer,
      ];
}

/// `Memo` executions metadata.
abstract class MemoExecutionsMetadata extends Equatable {
  MemoExecutionsMetadata(this.timeSpentInMillis, Map<MemoDifficulty, int> executionsAmounts)
      : _executionsAmounts = executionsAmounts,
        assert(
          (timeSpentInMillis > 0 && executionsAmounts.values.fold<int>(0, (a, b) => a + b) > 0) ||
              (timeSpentInMillis == 0 && executionsAmounts.values.fold<int>(0, (a, b) => a + b) == 0),
          'both properties must be simultaneously empty (zero) or not',
        );

  /// Total amount of time spent executing `Memo`s (in milliseconds).
  final int timeSpentInMillis;

  /// Maps each [MemoDifficulty] to its amount of executions.
  final Map<MemoDifficulty, int> _executionsAmounts;
  Map<MemoDifficulty, int> get executionsAmounts => Map.fromEntries(
        MemoDifficulty.values.map((difficulty) => MapEntry(difficulty, _executionsAmounts[difficulty] ?? 0)),
      );

  /// Sum of all [MemoDifficulty] executions amounts.
  int get totalExecutionsAmount => executionsAmounts.values.reduce((a, b) => a + b);
  bool get hasExecutions => totalExecutionsAmount > 0;

  @override
  List<Object?> get props => [timeSpentInMillis, executionsAmounts];
}
