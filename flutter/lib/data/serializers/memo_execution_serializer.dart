import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo_execution.dart';

class MemoExecutionKeys {
  static const collectionId = 'collectionId';
  static const started = 'started';
  static const finished = 'finished';
  static const id = 'id';
  static const question = 'question';
  static const answer = 'answer';
  static const markedDifficulty = 'markedDifficulty';
}

class MemoExecutionSerializer implements Serializer<MemoExecution, Map<String, dynamic>> {
  @override
  MemoExecution from(Map<String, dynamic> json) {
    final id = json[MemoExecutionKeys.id] as String;

    // TODO(matuella): Should we store as String or millis since epoch using UTC?
    final rawStarted = json[MemoExecutionKeys.started] as int;
    final started = DateTime.fromMillisecondsSinceEpoch(rawStarted, isUtc: true);
    // TODO(matuella): Should we store as String or millis since epoch using UTC?
    final rawFinished = json[MemoExecutionKeys.finished] as int;
    final finished = DateTime.fromMillisecondsSinceEpoch(rawFinished, isUtc: true);

    final question = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.question] as List);
    final answer = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.answer] as List);

    final rawDifficulty = json[MemoExecutionKeys.markedDifficulty] as String;
    final markedDifficulty = memoDifficultyFromRaw(rawDifficulty);

    return MemoExecution(
      id: id,
      question: question,
      answer: answer,
      started: started,
      finished: finished,
      markedDifficulty: markedDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(MemoExecution execution) => <String, dynamic>{
        MemoExecutionKeys.id: execution.id,
        // TODO(matuella): Should we store as String or millis since epoch using UTC?
        MemoExecutionKeys.started: execution.started.toUtc().millisecondsSinceEpoch,
        // TODO(matuella): Should we store as String or millis since epoch using UTC?
        MemoExecutionKeys.finished: execution.finished.toUtc().millisecondsSinceEpoch,
        MemoExecutionKeys.question: execution.question,
        MemoExecutionKeys.answer: execution.answer,
        MemoExecutionKeys.markedDifficulty: execution.markedDifficulty.raw,
      };
}
