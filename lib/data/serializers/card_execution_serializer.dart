import 'package:memo/core/faults/errors/serialization_error.dart';
import 'package:memo/data/serializers/card_block_serializer.dart';
import 'package:memo/data/serializers/serializer.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card_execution.dart';

class CardExecutionSerializer implements Serializer<CardExecution, Map<String, dynamic>> {
  final blockSerializer = CardBlockSerializer();

  @override
  CardExecution from(Map<String, dynamic> json) {
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

    return CardExecution(
      started: started,
      finished: finished,
      question: question,
      answer: answer,
      answeredDifficulty: answeredDifficulty,
    );
  }

  @override
  Map<String, dynamic> to(CardExecution execution) => <String, dynamic>{
        'started': execution.started.toUtc().millisecondsSinceEpoch,
        'finished': execution.finished.toUtc().millisecondsSinceEpoch,
        'answer': execution.answer.map(blockSerializer.to),
        'question': execution.question.map(blockSerializer.to),
        'answeredDifficulty': execution.answeredDifficulty.raw,
      };

  CardDifficulty _typeFromRaw(int raw) => CardDifficulty.values.firstWhere(
        (type) => type.raw == raw,
        orElse: () {
          throw SerializationError("Failed to find a CardDifficulty with the raw value of '$raw'");
        },
      );
}

extension on CardDifficulty {
  int get raw {
    switch (this) {
      case CardDifficulty.easy:
        return 1;
      case CardDifficulty.medium:
        return 2;
      case CardDifficulty.hard:
        return 3;
    }
  }
}

class CardExecutionsSerializer implements Serializer<CardExecutions, Map<String, dynamic>> {
  final executionSerializer = CardExecutionSerializer();

  @override
  CardExecutions from(Map<String, dynamic> json) {
    final cardId = json['cardId'] as String;
    final deckId = json['deckId'] as String;

    final rawExecutions = json['executions'] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final executions = rawExecutions.cast<Map<String, dynamic>>().map(executionSerializer.from).toList();

    return CardExecutions(cardId: cardId, deckId: deckId, executions: executions);
  }

  @override
  Map<String, dynamic> to(CardExecutions cardExecutions) => <String, dynamic>{
        'cardId': cardExecutions.cardId,
        'deckId': cardExecutions.deckId,
        'executions': cardExecutions.executions.map(executionSerializer.to).toList(),
      };
}
