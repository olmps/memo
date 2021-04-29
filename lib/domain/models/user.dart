import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Holds preferences and the user's application metadata (by extending [MemoExecutionsMetadata])
@immutable
class User extends MemoExecutionsMetadata {
  User({
    required this.memosExecutionChunkGoal,
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  }) : super(timeSpentInMillis, executionsAmounts);

  /// Amount of `Memo`s expected to be executed per chunk (given any `Collection`)
  final int memosExecutionChunkGoal;
}
