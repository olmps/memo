import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:meta/meta.dart';

/// Immutable history of a `Memo` execution.
@immutable
class MemoExecution extends Memo {
  MemoExecution({
    required String id,
    required List<Map<String, dynamic>> question,
    required List<Map<String, dynamic>> answer,
    required this.started,
    required this.finished,
    required this.markedDifficulty,
  })  : assert(started.isBefore(finished)),
        super(id: id, question: question, answer: answer);

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => finished.difference(started).inMilliseconds;

  final MemoDifficulty markedDifficulty;

  @override
  List<Object?> get props => [
        id,
        question,
        answer,
        started,
        finished,
        markedDifficulty,
      ];
}
