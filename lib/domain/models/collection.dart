import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:meta/meta.dart';

/// Defines all metadata of a collection (group) of its associated `Memo`s
///
/// A [Collection] not only holds the metadata for a group of `Memo`s (like [name], [category] and [description]) but
/// also deal with all the information about its executed `Memo`s, like [uniqueMemosAmount],
/// [uniqueMemoExecutionsAmount], and by extending the [MemoExecutionsMetadata], which are all a byproduct of the act of
/// executing an arbitrary number of `Memo`s.
@immutable
class Collection extends MemoExecutionsMetadata with EquatableMixin {
  Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.uniqueMemosAmount,
    this.uniqueMemoExecutionsAmount = 0,
    Map<MemoDifficulty, int> executionsAmounts = const {},
    int timeSpentInMillis = 0,
  })  : assert(uniqueMemosAmount > 0, 'must be a positive integer'),
        assert(uniqueMemoExecutionsAmount >= 0, 'must be a positive (or zero) integer'),
        assert(timeSpentInMillis >= 0, 'must be a positive (or zero) integer'),
        assert(
          uniqueMemosAmount >= uniqueMemoExecutionsAmount,
          'executions should never exceed the unique total amount',
        ),
        super(timeSpentInMillis, executionsAmounts);

  final String id;
  final String name;
  final String description;
  final String category;

  /// List of tags that can associate with this `Resource`
  ///
  /// This is useful in cases where we must match [Collection.tags] with each available resource(s)
  final List<String> tags;

  /// The total amount of unique `Memo`s (associated with this [Collection]) that have been executed at least once
  final int uniqueMemoExecutionsAmount;

  /// The total amount of unique `Memo`s associated with this [Collection]
  final int uniqueMemosAmount;

  /// `true` if this [Collection] has never executed any `Memo`
  bool get isPristine => uniqueMemoExecutionsAmount == 0;

  /// `true` if this [Collection] has executed (at least once) all of its `Memo`s
  bool get isCompleted => uniqueMemoExecutionsAmount == uniqueMemosAmount;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        uniqueMemoExecutionsAmount,
        uniqueMemosAmount,
        ...super.props,
      ];
}
