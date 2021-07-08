import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Defines the user preferences
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes all application-wide `Memo`s
/// executions.
@immutable
class User extends MemoExecutionsMetadata {
  User({
    required this.memosExecutionChunkGoal,
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  }) : super(timeSpentInMillis, executionsAmounts);

  /// Amount of `Memo`s expected to be executed per execution-event.
  final int memosExecutionChunkGoal;

  @override
  List<Object?> get props => [memosExecutionChunkGoal, ...super.props];
}
