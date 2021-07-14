import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Metadata for an unit of a collection - a `Memo`.
///
/// Stores the latest answer/question for this `Memo`, which can change over time.
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes its associated executions.
///
/// See also:
///   - `Collection`, which groups all metadata for the execution of its multiple associated `Memo`.
///   - `MemoExecution`, which represents an individual execution of a `Memo`.
@immutable
// ignore: avoid_implementing_value_types
class Memo extends MemoExecutionsMetadata with EquatableMixin implements MemoCollectionMetadata {
  Memo({
    required this.collectionId,
    required this.uniqueId,
    required this.rawQuestion,
    required this.rawAnswer,
    this.lastExecution,
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  })  : assert(
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

  /// Parent collection's id.
  final String collectionId;

  final MemoExecution? lastExecution;
  DateTime? get lastExecuted => lastExecution?.finished;
  MemoDifficulty? get lastMarkedDifficulty => lastExecution?.markedDifficulty;

  /// `true` if this [Memo] was never executed.
  bool get isPristine => lastExecution == null;

  @override
  List<Object?> get props => [collectionId, lastExecution, uniqueId, rawQuestion, rawAnswer, ...super.props];

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
