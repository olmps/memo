import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo.dart';

class MemoKeys {
  static const collectionId = 'collectionId';
  static const uniqueId = 'uniqueId';
  static const rawQuestion = 'question';
  static const rawAnswer = 'answer';
  static const executionsAmounts = 'executionsAmounts';
  static const lastExecution = 'lastExecution';
  static const timeSpentInMillis = 'timeSpentInMillis';
}

class MemoSerializer implements Serializer<Memo, Map<String, dynamic>> {
  final executionSerializer = MemoExecutionSerializer();

  @override
  Memo from(Map<String, dynamic> json) {
    final collectionId = json[MemoKeys.collectionId] as String;
    final uniqueId = json[MemoKeys.uniqueId] as String;

    final rawQuestion = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.rawQuestion] as List);
    final rawAnswer = List<Map<String, dynamic>>.from(json[MemoExecutionKeys.rawAnswer] as List);

    final rawExecutionsAmounts = json[MemoKeys.executionsAmounts] as Map<String, dynamic>?;
    final executionsAmounts =
        rawExecutionsAmounts?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[MemoKeys.timeSpentInMillis] as int?;

    final rawLastExecution = json[MemoKeys.lastExecution] as Map<String, dynamic>?;
    final lastExecution = rawLastExecution == null ? null : executionSerializer.from(rawLastExecution);

    return Memo(
      collectionId: collectionId,
      uniqueId: uniqueId,
      rawQuestion: rawQuestion,
      rawAnswer: rawAnswer,
      executionsAmounts: executionsAmounts ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
      lastExecution: lastExecution,
    );
  }

  @override
  Map<String, dynamic> to(Memo memo) => <String, dynamic>{
        MemoKeys.collectionId: memo.collectionId,
        MemoKeys.uniqueId: memo.uniqueId,
        MemoKeys.rawQuestion: memo.rawQuestion,
        MemoKeys.rawAnswer: memo.rawAnswer,
        MemoKeys.executionsAmounts: memo.executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
        MemoKeys.timeSpentInMillis: memo.timeSpentInMillis,
        if (memo.lastExecution != null) MemoKeys.lastExecution: executionSerializer.to(memo.lastExecution!),
      };
}
