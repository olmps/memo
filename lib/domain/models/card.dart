import 'package:equatable/equatable.dart';
import 'package:memo/data/database_repository.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:meta/meta.dart';

@immutable
class Card extends KeyStorable {
  const Card({
    required String id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.executionsAmount = 0,
    this.lastExecution,
    this.dueDate,
  })  : assert(executionsAmount >= 0, 'executionsAmount must be a positive (or zero) integer'),
        assert(
          (lastExecution == null && executionsAmount == 0) || (lastExecution != null && executionsAmount > 0),
          'If lastExecution is provided, the executionsAmount must be greater than 0',
        ),
        assert(
          (lastExecution == null && dueDate == null) || (lastExecution != null && dueDate != null),
          'Both lastExecution and dueDate must be simultaneously null or not null',
        ),
        super(id: id);

  final String deckId;

  /// Ordered blocks to represent this card's question and provide the necessary metadata
  final List<CardBlock> question;

  /// Ordered blocks to represent this card's answer and provide the necessary metadata
  final List<CardBlock> answer;

  /// The amount of times which this [Card] has been executed
  final int executionsAmount;

  final CardExecution? lastExecution;
  DateTime? get lastExecuted => lastExecution?.finished;

  /// The date which this [Card] is requires to be reviewed
  final DateTime? dueDate;

  /// `true` if this [Card] was never executed
  bool get isPristine => lastExecution == null;

  // TODO(matuella): Does `equatable` unwraps `List` properties for me, or will it always fail?
  // https://github.com/felangel/equatable/pull/103
  @override
  List<Object?> get props => [id, deckId, question, answer, executionsAmount, lastExecuted, lastExecution, dueDate];
}

/// Wraps the [rawContents] of a "segment" of the respective [Card] answer/question
///
/// This is just a single piece of a [Card]'s question or answer, which can be composed of multiple [CardBlock]s.
@immutable
class CardBlock extends Equatable {
  CardBlock({required this.type, required this.rawContents}) : assert(rawContents.isNotEmpty);

  final CardBlockType type;
  final String rawContents;

  @override
  List<Object?> get props => [type, rawContents];
}

/// Representation of the exact history (immutable) of a [Card] execution
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

/// Association of a `Deck.id` and all executions for a card with this particular `cardId`
@immutable
class DeckCardExecutions extends KeyStorable {
  DeckCardExecutions({required String cardId, required this.deckId, required this.answers})
      : assert(answers.isNotEmpty),
        super(id: cardId);

  final String deckId;
  final List<CardExecution> answers;

  // TODO(matuella): Does `equatable` unwraps `List` properties for me, or will it always fail?
  // https://github.com/felangel/equatable/pull/103
  @override
  List<Object?> get props => [id, answers];
}
