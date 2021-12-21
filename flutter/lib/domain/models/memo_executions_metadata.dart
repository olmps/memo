import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';

typedef TotalExecutions = int;

/// `Memo` executions metadata.
abstract class MemoExecutionsMetadata extends Equatable {
  MemoExecutionsMetadata(this.timeSpentInMillis, Map<MemoDifficulty, TotalExecutions> difficulties)
      :
        // Normalize executions difficulties by making sure that all dificulties have a related value, even if zero.
        executionsDifficulty = Map.fromEntries(
          MemoDifficulty.values.map((difficulty) => MapEntry(difficulty, difficulties[difficulty] ?? 0)),
        ),
        assert(timeSpentInMillis >= 0, 'must be a positive (or zero) integer'),
        assert(
          (timeSpentInMillis > 0 && difficulties.values.fold<int>(0, (a, b) => a + b) > 0) ||
              (timeSpentInMillis == 0 && difficulties.values.fold<int>(0, (a, b) => a + b) == 0),
          'both properties must be simultaneously empty (zero) or not',
        );

  /// Sum of all [MemoDifficulty] executions amounts.
  int get totalExecutionsAmount => executionsDifficulty.values.reduce((a, b) => a + b);
  bool get hasExecutions => totalExecutionsAmount > 0;

  /// Total amount of time spent executing `Memo`s (in milliseconds).
  final int timeSpentInMillis;

  /// Maps each [MemoDifficulty] to its amount of executions.
  final Map<MemoDifficulty, TotalExecutions> executionsDifficulty;

  @override
  List<Object?> get props => [timeSpentInMillis, executionsDifficulty];
}
