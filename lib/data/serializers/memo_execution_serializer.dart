import 'package:memo/core/faults/errors/serialization_error.dart';
import 'package:memo/data/serializers/memo_block_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';

class MemoExecutionSerializer implements Serializer<MemoExecution, Map<String, dynamic>> {
  final blockSerializer = MemoBlockSerializer();

  @override
  MemoExecution from(Map<String, dynamic> json) {
    final rawStarted = json['started'] as int;
    final started = DateTime.fromMillisecondsSinceEpoch(rawStarted, isUtc: true);

    final rawFinished = json['finished'] as int;
    final finished = DateTime.fromMillisecondsSinceEpoch(rawFinished, isUtc: true);

    final rawAnswer = json['answer'] as List;
    final rawQuestion = json['question'] as List;

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final answer = rawAnswer.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();
    final question = rawQuestion.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();

    final rawDifficulty = json['answeredDifficulty'] as int;
    final answeredDifficulty = _typeFromRaw(rawDifficulty);

    return MemoExecution(
      started: started,
      finished: finished,
      question: question,
      answer: answer,
      answeredDifficulty: answeredDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(MemoExecution execution) => <String, dynamic>{
        'started': execution.started.toUtc().millisecondsSinceEpoch,
        'finished': execution.finished.toUtc().millisecondsSinceEpoch,
        'answer': execution.answer.map(blockSerializer.to),
        'question': execution.question.map(blockSerializer.to),
        'answeredDifficulty': execution.answeredDifficulty.raw,
      };

  MemoDifficulty _typeFromRaw(int raw) => MemoDifficulty.values.firstWhere(
        (type) => type.raw == raw,
        orElse: () {
          throw SerializationError("Failed to find a MemoDifficulty with the raw value of '$raw'");
        },
      );
}

extension on MemoDifficulty {
  int get raw {
    switch (this) {
      case MemoDifficulty.easy:
        return 1;
      case MemoDifficulty.medium:
        return 2;
      case MemoDifficulty.hard:
        return 3;
    }
  }
}

class MemoExecutionsSerializer implements Serializer<MemoExecutions, Map<String, dynamic>> {
  final executionSerializer = MemoExecutionSerializer();

  @override
  MemoExecutions from(Map<String, dynamic> json) {
    final memoId = json['memoId'] as String;
    final collectionId = json['collectionId'] as String;

    final rawExecutions = json['executions'] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final executions = rawExecutions.cast<Map<String, dynamic>>().map(executionSerializer.from).toList();

    return MemoExecutions(memoId: memoId, collectionId: collectionId, executions: executions);
  }

  @override
  Map<String, dynamic> to(MemoExecutions memoExecutions) => <String, dynamic>{
        'memoId': memoExecutions.memoId,
        'collectionId': memoExecutions.collectionId,
        'executions': memoExecutions.executions.map(executionSerializer.to).toList(),
      };
}
