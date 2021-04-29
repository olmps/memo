import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Defines a unit of a `Collection`
///
/// A [Memo] simply wraps a [rawQuestion] and its respective [rawAnswer]. Because each [Memo] can be executed an
/// infinite amount of times, its purpose is to store the most recent version of its question/answer with useful
/// execution's metadata, like [lastExecution] and by extending [MemoExecutionsMetadata].
@immutable
class Memo extends MemoExecutionsMetadata with EquatableMixin implements MemoCollectionMetadata {
  Memo({
    required this.collectionId,
    required this.uniqueId,
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

  @override
  final String uniqueId;

  @override
  final List<Map<String, dynamic>> rawQuestion;

  @override
  final List<Map<String, dynamic>> rawAnswer;

  /// Parent's `Collection.id`
  final String collectionId;

  final MemoExecution? lastExecution;
  DateTime? get lastExecuted => lastExecution?.finished;
  MemoDifficulty? get lastMarkedDifficulty => lastExecution?.markedDifficulty;

  /// `true` if this [Memo] was never executed
  bool get isPristine => lastExecution == null;

  @override
  List<Object?> get props => [collectionId, uniqueId, rawQuestion, rawAnswer, lastExecution, ...super.props];

  Memo copyWith({
    List<Map<String, dynamic>>? rawQuestion,
    List<Map<String, dynamic>>? rawAnswer,
    MemoExecution? lastExecution,
    Map<MemoDifficulty, int>? executionsAmounts,
    int? timeSpentInMillis,
  }) {
    return Memo(
      collectionId: collectionId,
      uniqueId: uniqueId,
      rawQuestion: rawQuestion ?? this.rawQuestion,
      rawAnswer: rawAnswer ?? this.rawAnswer,
      lastExecution: lastExecution ?? this.lastExecution,
      executionsAmounts: executionsAmounts ?? this.executionsAmounts,
      timeSpentInMillis: timeSpentInMillis ?? this.timeSpentInMillis,
    );
  }
}
