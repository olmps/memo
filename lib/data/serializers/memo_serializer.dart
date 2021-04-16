import 'package:memo/data/serializers/memo_block_serializer.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';

class MemoSerializer implements Serializer<Memo, Map<String, dynamic>> {
  final blockSerializer = MemoBlockSerializer();
  final executionSerializer = MemoExecutionSerializer();

  @override
  Memo from(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final collectionId = json['collectionId'] as String;

    final rawAnswer = json['answer'] as List;
    final rawQuestion = json['question'] as List;

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final answer = rawAnswer.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();
    final question = rawQuestion.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();

    final executionsAmount = json['executionsAmount'] as int;

    MemoExecution? lastExecution;
    if (json.containsKey('lastExecution')) {
      final rawLastExecution = json['lastExecution'] as Map<String, dynamic>;
      lastExecution = executionSerializer.from(rawLastExecution);
    }

    DateTime? dueDate;
    if (json.containsKey('dueDate')) {
      final rawDueDate = json['dueDate'] as int;
      dueDate = DateTime.fromMillisecondsSinceEpoch(rawDueDate, isUtc: true);
    }

    return Memo(
      id: id,
      collectionId: collectionId,
      question: question,
      answer: answer,
      executionsAmount: executionsAmount,
      lastExecution: lastExecution,
      dueDate: dueDate,
    );
  }

  @override
  Map<String, dynamic> to(Memo memo) => <String, dynamic>{
        'id': memo.id,
        'collectionId': memo.collectionId,
        'answer': memo.answer.map(blockSerializer.to),
        'question': memo.question.map(blockSerializer.to),
        'executionsAmount': memo.executionsAmount,
        if (memo.lastExecution != null) 'lastExecution': executionSerializer.to(memo.lastExecution!),
        if (memo.dueDate != null) 'dueDate': memo.dueDate!.toUtc().millisecondsSinceEpoch,
      };
}
