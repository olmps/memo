import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:meta/meta.dart';

/// Representation of the exact history (immutable) of a `Memo` execution
@immutable
class MemoExecution extends Equatable {
  MemoExecution({
    required this.memoId,
    required this.collectionId,
    required this.started,
    required this.finished,
    required this.rawQuestion,
    required this.rawAnswer,
    required this.markedDifficulty,
  })   : assert(started.isBefore(finished)),
        assert(rawQuestion.isNotEmpty),
        assert(rawQuestion.first.isNotEmpty),
        assert(rawAnswer.isNotEmpty),
        assert(rawAnswer.first.isNotEmpty);

  final String memoId;
  final String collectionId;

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => started.difference(finished).inMilliseconds;

  final List<Map<String, dynamic>> rawQuestion;
  final List<Map<String, dynamic>> rawAnswer;

  final MemoDifficulty markedDifficulty;

  @override
  List<Object?> get props => [started, finished, rawQuestion, rawAnswer, markedDifficulty];
}

/// Defines the shared metadata about one or multiple `Memo` executions
abstract class MemoExecutionsMetadata extends Equatable {
  MemoExecutionsMetadata(this.timeSpentInMillis, this.executionsAmounts)
      : assert(
          (timeSpentInMillis > 0 && executionsAmounts.isNotEmpty) ||
              (timeSpentInMillis == 0 && executionsAmounts.isEmpty),
          'both properties must be simultaneously empty (zero) or not',
        );

  /// The total amount of time spent executing `Memo`s (in milliseconds)
  final int timeSpentInMillis;

  /// Maps each [MemoDifficulty] to its amount of executions
  final Map<MemoDifficulty, int> executionsAmounts;

  /// The total amount of [MemoDifficulty.easy] answers
  int get easyMemoExecutionsAmount => executionsAmounts[MemoDifficulty.easy] ?? 0;

  /// The total amount of [MemoDifficulty.medium] answers
  int get mediumMemoExecutionsAmount => executionsAmounts[MemoDifficulty.medium] ?? 0;

  /// The total amount of [MemoDifficulty.hard] answers
  int get hardMemoExecutionsAmount => executionsAmounts[MemoDifficulty.hard] ?? 0;

  /// Sum of all [MemoDifficulty] executions amounts
  int get totalExecutionsAmount => easyMemoExecutionsAmount + mediumMemoExecutionsAmount + hardMemoExecutionsAmount;

  @override
  List<Object?> get props => [timeSpentInMillis, executionsAmounts];
}
