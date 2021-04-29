import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:meta/meta.dart';

/// Representation of the exact history (immutable) of a `Memo` execution
@immutable
class MemoExecution extends Equatable implements MemoCollectionMetadata {
  MemoExecution({
    required this.collectionId,
    required this.started,
    required this.finished,
    required this.uniqueId,
    required this.rawQuestion,
    required this.rawAnswer,
    required this.markedDifficulty,
  })   : assert(started.isBefore(finished)),
        assert(rawQuestion.isNotEmpty),
        assert(rawQuestion.first.isNotEmpty),
        assert(rawAnswer.isNotEmpty),
        assert(rawAnswer.first.isNotEmpty);

  final String collectionId;

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => finished.difference(started).inMilliseconds;

  @override
  final String uniqueId;

  @override
  final List<Map<String, dynamic>> rawQuestion;

  @override
  final List<Map<String, dynamic>> rawAnswer;

  final MemoDifficulty markedDifficulty;

  @override
  List<Object?> get props => [
        collectionId,
        started,
        finished,
        uniqueId,
        rawQuestion,
        rawAnswer,
        markedDifficulty,
      ];
}

/// Defines the shared metadata about one or multiple `Memo` executions
abstract class MemoExecutionsMetadata extends Equatable {
  MemoExecutionsMetadata(this.timeSpentInMillis, Map<MemoDifficulty, int> executionsAmounts)
      : _executionsAmounts = executionsAmounts,
        assert(
          (timeSpentInMillis > 0 && executionsAmounts.values.fold<int>(0, (a, b) => a + b) > 0) ||
              (timeSpentInMillis == 0 && executionsAmounts.values.fold<int>(0, (a, b) => a + b) == 0),
          'both properties must be simultaneously empty (zero) or not',
        );

  /// The total amount of time spent executing `Memo`s (in milliseconds)
  final int timeSpentInMillis;

  /// Maps each [MemoDifficulty] to its amount of executions
  final Map<MemoDifficulty, int> _executionsAmounts;
  Map<MemoDifficulty, int> get executionsAmounts => Map.fromEntries(
        MemoDifficulty.values.map((difficulty) => MapEntry(difficulty, _executionsAmounts[difficulty] ?? 0)),
      );

  /// Sum of all [MemoDifficulty] executions amounts
  int get totalExecutionsAmount => executionsAmounts.values.reduce((a, b) => a + b);
  bool get hasExecutions => totalExecutionsAmount > 0;

  @override
  List<Object?> get props => [timeSpentInMillis, _executionsAmounts];
}
