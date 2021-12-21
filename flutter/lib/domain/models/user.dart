import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_executions_metadata.dart';
import 'package:meta/meta.dart';

/// Defines the user preferences
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes all user-wide `Memo`s
/// executions.
@immutable
class User extends MemoExecutionsMetadata {
  User({
    required this.id,
    required this.executionChunk,
    Map<MemoDifficulty, int> executionsDifficulty = const {},
    int timeSpentInMillis = 0,
  }) : super(timeSpentInMillis, executionsDifficulty);

  final String id;

  /// Amount of `Memo`s expected to be executed per execution-event.
  final int executionChunk;

  @override
  List<Object?> get props => [executionChunk, ...super.props];
}
