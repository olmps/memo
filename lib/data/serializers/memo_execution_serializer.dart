import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo_execution.dart';

class MemoExecutionKeys {
  static const started = 'started';
  static const finished = 'finished';
  static const rawQuestion = 'question';
  static const rawAnswer = 'answer';
  static const markedDifficulty = 'markedDifficulty';
}

class MemoExecutionSerializer implements Serializer<MemoExecution, Map<String, dynamic>> {
  @override
  MemoExecution from(Map<String, dynamic> json) {
    final rawStarted = json[MemoExecutionKeys.started] as int;
    final started = DateTime.fromMillisecondsSinceEpoch(rawStarted, isUtc: true);

    final rawFinished = json[MemoExecutionKeys.finished] as int;
    final finished = DateTime.fromMillisecondsSinceEpoch(rawFinished, isUtc: true);

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final rawQuestion = (json[MemoExecutionKeys.rawQuestion] as List).cast<Map<String, dynamic>>();
    final rawAnswer = (json[MemoExecutionKeys.rawAnswer] as List).cast<Map<String, dynamic>>();

    final rawDifficulty = json[MemoExecutionKeys.markedDifficulty] as String;
    final markedDifficulty = memoDifficultyFromRaw(rawDifficulty);

    return MemoExecution(
      started: started,
      finished: finished,
      rawQuestion: rawQuestion,
      rawAnswer: rawAnswer,
      markedDifficulty: markedDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(MemoExecution execution) => <String, dynamic>{
        MemoExecutionKeys.started: execution.started.toUtc().millisecondsSinceEpoch,
        MemoExecutionKeys.finished: execution.finished.toUtc().millisecondsSinceEpoch,
        MemoExecutionKeys.rawQuestion: execution.rawQuestion,
        MemoExecutionKeys.rawAnswer: execution.rawAnswer,
        MemoExecutionKeys.markedDifficulty: execution.markedDifficulty.raw,
      };
}

//
// UniqueMemoExecutions
//

class UniqueMemoExecutionsKeys {
  static const memoId = 'memoId';
  static const collectionId = 'collectionId';
  static const executions = 'executions';
}

class UniqueMemoExecutionsSerializer implements Serializer<UniqueMemoExecutions, Map<String, dynamic>> {
  final executionSerializer = MemoExecutionSerializer();

  @override
  UniqueMemoExecutions from(Map<String, dynamic> json) {
    final memoId = json[UniqueMemoExecutionsKeys.memoId] as String;
    final collectionId = json[UniqueMemoExecutionsKeys.collectionId] as String;

    final rawExecutions = json[UniqueMemoExecutionsKeys.executions] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final executions = rawExecutions.cast<Map<String, dynamic>>().map(executionSerializer.from).toList();

    return UniqueMemoExecutions(memoId: memoId, collectionId: collectionId, executions: executions);
  }

  @override
  Map<String, dynamic> to(UniqueMemoExecutions memoExecutions) => <String, dynamic>{
        UniqueMemoExecutionsKeys.memoId: memoExecutions.memoId,
        UniqueMemoExecutionsKeys.collectionId: memoExecutions.collectionId,
        UniqueMemoExecutionsKeys.executions: memoExecutions.executions.map(executionSerializer.to).toList(),
      };
}
