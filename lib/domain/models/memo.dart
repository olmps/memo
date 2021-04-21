import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Defines a unit of a `Collection`
///
/// A [Memo] simply wraps a [rawQuestion] and its respective [rawAnswer]. Because each [Memo] can be executed an
/// infinite amount of times, its purpose is to store the most recent version of its question/answer with useful
/// execution's metadata, like [lastExecution] and by extending [MemoExecutionsMetadata].
@immutable
class Memo extends MemoExecutionsMetadata with EquatableMixin {
  Memo({
    required this.id,
    required this.collectionId,
    required this.rawQuestion,
    required this.rawAnswer,
    this.lastExecution,
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  })  : assert(rawQuestion.isNotEmpty),
        assert(rawQuestion.first.isNotEmpty),
        assert(rawAnswer.isNotEmpty),
        assert(rawAnswer.first.isNotEmpty),
        assert(
          (timeSpentInMillis > 0 && lastExecution != null) || (timeSpentInMillis == 0 && lastExecution == null),
          'both properties must be simultaneously empty (zero) or not',
        ),
        super(timeSpentInMillis, executionsAmounts);

  final String id;

  /// Parent's `Collection.id`
  final String collectionId;

  /// Raw representation of a `Memo` question
  ///
  /// Because a question may be composed of an arbitrary amount of styled elements, each raw "block", "piece", or even
  /// an "element", will have a completely different structure from each other. In this scenario, a [List] of [Map]
  /// (the latter which is usually a JSON) is a reasonable fit for this  customized structure.
  final List<Map<String, dynamic>> rawQuestion;

  /// Raw representation of a `Memo` answer
  ///
  /// Because an answer may be composed of an arbitrary amount of styled elements, each raw "block", "piece", or even
  /// an "element", will have a completely different structure from each other. In this scenario, a [List] of [Map]
  /// (the latter which is usually a JSON) is a reasonable fit for this  customized structure.
  final List<Map<String, dynamic>> rawAnswer;

  final MemoExecution? lastExecution;
  DateTime? get lastExecuted => lastExecution?.finished;
  MemoDifficulty? get lastMarkedDifficulty => lastExecution?.markedDifficulty;

  /// `true` if this [Memo] was never executed
  bool get isPristine => lastExecution == null;

  @override
  List<Object?> get props => [
        id,
        collectionId,
        rawQuestion,
        rawAnswer,
        lastExecution,
        ...super.props,
      ];
}
