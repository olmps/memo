import 'package:memo/data/serializers/card_block_serializer.dart';
import 'package:memo/data/serializers/card_execution_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/models/card.dart';
import 'package:memo/domain/models/card_execution.dart';

class CardSerializer implements Serializer<Card, Map<String, dynamic>> {
  final blockSerializer = CardBlockSerializer();
  final executionSerializer = CardExecutionSerializer();

  @override
  Card from(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final deckId = json['deckId'] as String;

    final rawAnswer = json['answer'] as List;
    final rawQuestion = json['question'] as List;

    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final answer = rawAnswer.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();
    final question = rawQuestion.cast<Map<String, dynamic>>().map(blockSerializer.from).toList();

    final executionsAmount = json['executionsAmount'] as int;

    CardExecution? lastExecution;
    if (json.containsKey('lastExecution')) {
      final rawLastExecution = json['lastExecution'] as Map<String, dynamic>;
      lastExecution = executionSerializer.from(rawLastExecution);
    }

    DateTime? dueDate;
    if (json.containsKey('dueDate')) {
      final rawDueDate = json['dueDate'] as int;
      dueDate = DateTime.fromMillisecondsSinceEpoch(rawDueDate, isUtc: true);
    }

    return Card(
      id: id,
      deckId: deckId,
      question: question,
      answer: answer,
      executionsAmount: executionsAmount,
      lastExecution: lastExecution,
      dueDate: dueDate,
    );
  }

  @override
  Map<String, dynamic> to(Card card) => <String, dynamic>{
        'id': card.id,
        'deckId': card.deckId,
        'answer': card.answer.map(blockSerializer.to),
        'question': card.question.map(blockSerializer.to),
        'executionsAmount': card.executionsAmount,
        if (card.lastExecution != null) 'lastExecution': executionSerializer.to(card.lastExecution!),
        if (card.dueDate != null) 'dueDate': card.dueDate!.toUtc().millisecondsSinceEpoch,
      };
}
