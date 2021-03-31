import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:meta/meta.dart';

/// Representation of the exact history (immutable) of a `Card` execution
@immutable
class CardExecution extends Equatable {
  CardExecution({
    required this.started,
    required this.finished,
    required this.question,
    required this.answer,
    required this.answeredDifficulty,
  })   : assert(started.isBefore(finished)),
        assert(question.isNotEmpty),
        assert(answer.isNotEmpty);

  final DateTime started;
  final DateTime finished;
  int get timeSpentInMillis => started.difference(finished).inMilliseconds;

  final List<CardBlock> question;
  final List<CardBlock> answer;

  final CardDifficulty answeredDifficulty;

  @override
  List<Object?> get props => [started, finished, question, answer, answeredDifficulty];
}

/// Associates a `Deck.id` and all executions for a card with its particular `cardId`
@immutable
class CardExecutions extends Equatable {
  CardExecutions({required this.cardId, required this.deckId, required this.executions})
      : assert(executions.isNotEmpty);

  final String cardId;
  final String deckId;
  final List<CardExecution> executions;

  @override
  List<Object?> get props => [cardId, deckId, executions];
}
