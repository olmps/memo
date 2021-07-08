import 'package:equatable/equatable.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';
import 'package:memo/domain/models/contributor.dart';
import 'package:meta/meta.dart';

/// Metadata for a collection (group) of its associated `Memo`s.
///
/// Through [MemoExecutionsMetadata], this class also includes properties that describes its executed `Memo`s.
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

  /// `true` if this [Collection] has never executed any `Memo`.
  bool get isPristine => uniqueMemoExecutionsAmount == 0;

  /// `true` if this [Collection] has executed (at least once) all of its `Memo`s.
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

/// Metadata for a collection.
abstract class CollectionMetadata {
  String get id;
  String get name;
  String get description;
  String get category;

  /// Abstract tags that are used to group and identify this collection.
  List<String> get tags;

  /// Contributors (or owners) that have created (or made changes) to this collection.
  List<Contributor> get contributors;

  /// Total amount of unique `Memo`s associated with this collection.
  int get uniqueMemosAmount;

  /// Total amount of unique `Memo`s associated with this collection that have been executed at least once.
  int get uniqueMemoExecutionsAmount;
}
