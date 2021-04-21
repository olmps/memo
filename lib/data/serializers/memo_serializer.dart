import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo.dart';

class MemoKeys {
  static const id = 'id';
  static const collectionId = 'collectionId';
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
    final id = json[MemoKeys.id] as String;
    final collectionId = json[MemoKeys.collectionId] as String;

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final rawQuestion = (json[MemoKeys.rawQuestion] as List).cast<Map<String, dynamic>>();
    final rawAnswer = (json[MemoKeys.rawAnswer] as List).cast<Map<String, dynamic>>();

    final rawExecutionsAmounts = json[MemoKeys.executionsAmounts] as Map<String, dynamic>?;
    final executionsAmounts =
        // ignore: avoid_annotating_with_dynamic
        rawExecutionsAmounts?.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    final timeSpentInMillis = json[MemoKeys.timeSpentInMillis] as int?;

    final rawLastExecution = json[MemoKeys.lastExecution] as Map<String, dynamic>?;
    final lastExecution = rawLastExecution == null ? null : executionSerializer.from(rawLastExecution);

    return Memo(
      id: id,
      collectionId: collectionId,
      rawQuestion: rawQuestion,
      rawAnswer: rawAnswer,
      executionsAmounts: executionsAmounts ?? {},
      timeSpentInMillis: timeSpentInMillis ?? 0,
      lastExecution: lastExecution,
    );
  }

  @override
  Map<String, dynamic> to(Memo memo) => <String, dynamic>{
        MemoKeys.id: memo.id,
        MemoKeys.collectionId: memo.collectionId,
        MemoKeys.rawQuestion: memo.rawQuestion,
        MemoKeys.rawAnswer: memo.rawAnswer,
        MemoKeys.executionsAmounts: memo.executionsAmounts.map((key, value) => MapEntry(key.raw, value)),
        MemoKeys.timeSpentInMillis: memo.timeSpentInMillis,
        if (memo.lastExecution != null) MemoKeys.lastExecution: executionSerializer.to(memo.lastExecution!),
      };
}
