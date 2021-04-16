import 'package:equatable/equatable.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Defines a unit of a `Collection`
///
/// A [Memo] simply wraps a [question] and its respective [answer]. Because each [Memo] can be executed an infinite
/// amount of times, the [Memo] only stores its metadata representing all other executions, like [lastExecution] and
/// [executionsAmount].
@immutable
class Memo extends Equatable {
  Memo({
    required this.id,
    required this.collectionId,
    required this.question,
    required this.answer,
    this.executionsAmount = 0,
    this.lastExecution,
    this.dueDate,
  })  : assert(executionsAmount >= 0, 'must be a positive (or zero) integer'),
        assert(question.isNotEmpty),
        assert(answer.isNotEmpty),
        assert(
          (lastExecution == null && executionsAmount == 0) || (lastExecution != null && executionsAmount > 0),
          'If the last execution is provided, the executions amount must be greater than 0, and vice versa',
        ),
        assert(
          (lastExecution == null && dueDate == null) || (lastExecution != null && dueDate != null),
          'Both last execution and due date must be simultaneously null or not null',
        );

  final String id;

  /// Parent's `Collection.id`
  final String collectionId;

  /// Ordered blocks to represent this memo's question and provide the necessary metadata
  final List<MemoBlock> question;

  /// Ordered blocks to represent this memo's answer and provide the necessary metadata
  final List<MemoBlock> answer;

  /// The amount of times which this [Memo] has been executed
  final int executionsAmount;

  final MemoExecution? lastExecution;
  DateTime? get lastExecuted => lastExecution?.finished;

  /// Following the memory algorithm, the date which this [Memo] is requires to be reviewed
  ///
  /// More about this here:
  // TODO(matuella): add reference to the algorithm when implemented.
  final DateTime? dueDate;

  /// `true` if this [Memo] was never executed
  bool get isPristine => lastExecution == null;

  @override
  List<Object?> get props => [
        id,
        collectionId,
        question,
        answer,
        executionsAmount,
        lastExecuted,
        lastExecution,
        dueDate,
      ];
}
