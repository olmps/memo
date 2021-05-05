import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo_execution.dart';

class MemoExecutionKeys {
  static const collectionId = 'collectionId';
  static const started = 'started';
  static const finished = 'finished';
  static const uniqueId = 'uniqueId';
  static const rawQuestion = 'question';
  static const rawAnswer = 'answer';
  static const markedDifficulty = 'markedDifficulty';
}

class MemoExecutionSerializer implements Serializer<MemoExecution, Map<String, dynamic>> {
  @override
  MemoExecution from(Map<String, dynamic> json) {
    final uniqueId = json[MemoExecutionKeys.uniqueId] as String;
    final collectionId = json[MemoExecutionKeys.collectionId] as String;

    final rawStarted = json[MemoExecutionKeys.started] as int;
    final started = DateTime.fromMillisecondsSinceEpoch(rawStarted, isUtc: true);

    final rawFinished = json[MemoExecutionKeys.finished] as int;
    final finished = DateTime.fromMillisecondsSinceEpoch(rawFinished, isUtc: true);

    final rawQuestion = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.rawQuestion] as List);
    final rawAnswer = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.rawAnswer] as List);

    final rawDifficulty = json[MemoExecutionKeys.markedDifficulty] as String;
    final markedDifficulty = memoDifficultyFromRaw(rawDifficulty);

    return MemoExecution(
      collectionId: collectionId,
      started: started,
      finished: finished,
      uniqueId: uniqueId,
      rawQuestion: rawQuestion,
      rawAnswer: rawAnswer,
      markedDifficulty: markedDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(MemoExecution execution) => <String, dynamic>{
        MemoExecutionKeys.collectionId: execution.collectionId,
        MemoExecutionKeys.started: execution.started.toUtc().millisecondsSinceEpoch,
        MemoExecutionKeys.finished: execution.finished.toUtc().millisecondsSinceEpoch,
        MemoExecutionKeys.uniqueId: execution.uniqueId,
        MemoExecutionKeys.rawQuestion: execution.rawQuestion,
        MemoExecutionKeys.rawAnswer: execution.rawAnswer,
        MemoExecutionKeys.markedDifficulty: execution.markedDifficulty.raw,
      };
}
