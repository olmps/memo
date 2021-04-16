import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:meta/meta.dart';

/// Representation of the exact history (immutable) of a `Memo` execution
@immutable
class MemoExecution extends Equatable {
  MemoExecution({
    required this.started,
    required this.finished,
    required this.question,
    required this.answer,
    required this.answeredDifficulty,
  })   : assert(started.isBefore(finished)),
        assert(question.isNotEmpty),
        assert(answer.isNotEmpty);

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => started.difference(finished).inMilliseconds;

  final List<MemoBlock> question;
  final List<MemoBlock> answer;

  final MemoDifficulty answeredDifficulty;

  @override
  List<Object?> get props => [started, finished, question, answer, answeredDifficulty];
}

/// Associates a `Collection.id` and all its executions of a particular memo, through its [memoId]
@immutable
class MemoExecutions extends Equatable {
  MemoExecutions({required this.memoId, required this.collectionId, required this.executions})
      : assert(executions.isNotEmpty);

  final String memoId;
  final String collectionId;
  final List<MemoExecution> executions;

  @override
  List<Object?> get props => [memoId, collectionId, executions];
}
