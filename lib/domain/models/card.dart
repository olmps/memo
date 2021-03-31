import 'package:equatable/equatable.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/models/card_execution.dart';
import 'package:meta/meta.dart';

@immutable
class Card extends Equatable {
  Card({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    this.executionsAmount = 0,
    this.lastExecution,
    this.dueDate,
  })  : assert(executionsAmount >= 0, 'executionsAmount must be a positive (or zero) integer'),
        assert(question.isNotEmpty),
        assert(answer.isNotEmpty),
        assert(
          (lastExecution == null && executionsAmount == 0) || (lastExecution != null && executionsAmount > 0),
          'If lastExecution is provided, the executionsAmount must be greater than 0, and vice versa',
        ),
        assert(
          (lastExecution == null && dueDate == null) || (lastExecution != null && dueDate != null),
          'Both lastExecution and dueDate must be simultaneously null or not null',
        );

  final String id;

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

  @override
  List<Object?> get props => [id, deckId, question, answer, executionsAmount, lastExecuted, lastExecution, dueDate];
}
