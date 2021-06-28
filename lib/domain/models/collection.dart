import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:meta/meta.dart';

/// Defines all metadata of a collection (group) of its associated `Memo`s
///
/// A [Collection] not only holds the metadata for a group of `Memo`s (like [name], [category] and [description]) but
/// also deal with all the information about its executed `Memo`s, like [uniqueMemosAmount],
/// [uniqueMemoExecutionsAmount], and by extending the [MemoExecutionsMetadata], which are all a byproduct of the act of
/// executing an arbitrary number of `Memo`s.
@immutable
class Collection extends MemoExecutionsMetadata with EquatableMixin implements CollectionMetadata {
  Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.uniqueMemosAmount,
    required this.contributors,
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

  @override
  final String id;

  @override
  final String name;

  @override
  final String description;

  @override
  final String category;

  @override
  final List<String> tags;

  @override
  final List<Contributor> contributors;

  @override
  final int uniqueMemosAmount;

  @override
  final int uniqueMemoExecutionsAmount;

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
        contributors,
        uniqueMemoExecutionsAmount,
        uniqueMemosAmount,
        ...super.props,
      ];
}

/// Represents all `Collection` metadata
abstract class CollectionMetadata {
  String get id;
  String get name;
  String get description;
  String get category;

  /// List of tags that can associate with this `Resource`
  ///
  /// This is useful in cases where we must match [Collection.tags] with each available resource(s)
  List<String> get tags;

  List<Contributor> get contributors;

  /// The total amount of unique `Memo`s associated with this [Collection]
  int get uniqueMemosAmount;

  /// The total amount of unique `Memo`s (associated with this [Collection]) that have been executed at least once
  int get uniqueMemoExecutionsAmount;
}
