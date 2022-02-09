import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/collection_execution.dart';

class CollectionExecutionKeys {
  static const id = 'id';
  static const executions = 'executions';
  static const isPrivate = 'isPrivate';
  static const timeSpentInMillis = 'timeSpentInMillis';
  static const executionsDifficulty = 'executionsDifficulty';
}

class CollectionExecutionSerializer implements Serializer<CollectionExecution, Map<String, dynamic>> {
  final memoExecutionRecallMetadataSerializer = MemoExecutionRecallMetadataSerializer();

  @override
  CollectionExecution from(Map<String, dynamic> json) {
    final id = json[CollectionExecutionKeys.id] as String;

    final rawExecutions = json[CollectionExecutionKeys.executions] as Map<String, dynamic>;
    final executions = rawExecutions.map<String, MemoExecutionRecallMetadata>((key, dynamic value) =>
        MapEntry(key, memoExecutionRecallMetadataSerializer.from(value as Map<String, dynamic>)));

    final isPrivate = json[CollectionExecutionKeys.isPrivate] as bool;

    final timeSpentInMillis = json[CollectionExecutionKeys.timeSpentInMillis] as int;
    final rawExecutionsDifficulty = json[CollectionExecutionKeys.executionsDifficulty] as Map<String, dynamic>;
    final executionsDifficulty =
        rawExecutionsDifficulty.map((key, dynamic value) => MapEntry(memoDifficultyFromRaw(key), value as int));

    return CollectionExecution(
      id: id,
      executions: executions,
      isPrivate: isPrivate,
      timeSpentInMillis: timeSpentInMillis,
      difficulties: executionsDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(CollectionExecution execution) => <String, dynamic>{
        CollectionExecutionKeys.id: execution.id,
        CollectionExecutionKeys.executions: execution.executions
            .map((key, metadata) => MapEntry(key, memoExecutionRecallMetadataSerializer.to(metadata))),
        CollectionExecutionKeys.timeSpentInMillis: execution.timeSpentInMillis,
        CollectionExecutionKeys.executionsDifficulty:
            execution.executionsDifficulty.map((key, value) => MapEntry(key.raw, value)),
      };
}

class MemoExecutionRecallMetadataKeys {
  static const id = 'id';
  static const totalExecutions = 'totalExecutions';
  static const lastExecution = 'lastExecution';
  static const lastMarkedDifficulty = 'lastMarkedDifficulty';
}

class MemoExecutionRecallMetadataSerializer implements Serializer<MemoExecutionRecallMetadata, Map<String, dynamic>> {
  @override
  MemoExecutionRecallMetadata from(Map<String, dynamic> json) {
    final id = json[MemoExecutionRecallMetadataKeys.id] as String;
    final totalExecutions = json[MemoExecutionRecallMetadataKeys.totalExecutions] as int;

    // TODO(matuella): Should we store as String or millis since epoch using UTC?
    // DateTime.fromMillisecondsSinceEpoch(lastExecution, isUtc: true);
    final lastExecution = json[MemoExecutionRecallMetadataKeys.lastExecution] as DateTime;
    final rawLastMarkedDifficulty = json[MemoExecutionRecallMetadataKeys.lastMarkedDifficulty] as String?;
    final lastMarkedDifficulty =
        rawLastMarkedDifficulty != null ? memoDifficultyFromRaw(rawLastMarkedDifficulty) : null;

    return MemoExecutionRecallMetadata(
      id: id,
      totalExecutions: totalExecutions,
      lastExecution: lastExecution,
      lastMarkedDifficulty: lastMarkedDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(MemoExecutionRecallMetadata execution) => <String, dynamic>{
        MemoExecutionRecallMetadataKeys.id: execution.id,
        // TODO(matuella): Should we store as String or millis since epoch using UTC?
        MemoExecutionRecallMetadataKeys.totalExecutions: execution.totalExecutions,
        if (execution.lastExecution != null) MemoExecutionRecallMetadataKeys.lastExecution: execution.lastExecution,
        if (execution.lastMarkedDifficulty != null)
          MemoExecutionRecallMetadataKeys.lastMarkedDifficulty: execution.lastMarkedDifficulty?.raw,
      };
}
