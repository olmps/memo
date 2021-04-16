import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Defines all metadata of a collection (group) of its associated `Memo`s
///
/// A [Collection] not only holds the metadata for a group of `Memo`s (like [name], [category] and [description]) but
/// also deal with all the information about its executed `Memo`s, like [timeSpentInMillis] and [memoryStability], which
/// are a byproduct of the act of executing an arbitrary number of `Memo`s.
@immutable
class Collection extends Equatable {
  const Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    this.timeSpentInMillis = 0,
    this.easyMemosAmount = 0,
    this.mediumMemosAmount = 0,
    this.hardMemosAmount = 0,
    this.memoryStability,
  })  : assert(timeSpentInMillis >= 0, 'must be a positive (or zero) integer'),
        assert(
          (timeSpentInMillis == 0 && memoryStability == null) || (timeSpentInMillis > 0 && memoryStability != null),
          'must not be null when timeSpentInMillis is positive',
        ),
        assert(easyMemosAmount >= 0, 'must be a positive (or zero) integer'),
        assert(mediumMemosAmount >= 0, 'must be a positive (or zero) integer'),
        assert(hardMemosAmount >= 0, 'must be a positive (or zero) integer');

  final String id;
  final String name;
  final String description;
  final String category;

  /// List of tags that can associate with this `Resource`
  ///
  /// This is useful in cases where we must match [Collection.tags] with each available resource(s)
  final List<String> tags;

  /// The total amount of time spent executing `Memo`s for this collection (in milliseconds)
  final int timeSpentInMillis;

  /// The total amount of easy answers (`MemoDifficulty`) for this collection
  final int easyMemosAmount;

  /// The total amount of medium answers (`MemoDifficulty`) for this collection
  final int mediumMemosAmount;

  /// The total amount of hard answers (`MemoDifficulty`) for this collection
  final int hardMemosAmount;

  /// Following the stability algorithm, represents a floating number that ranges from 0 and 1
  ///
  /// More about this here:
  // TODO(matuella): add reference to the algorithm when implemented.
  final double? memoryStability;

  /// `true` if this [Collection] has never executed any `Memo`
  bool get isPristine => timeSpentInMillis == 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        timeSpentInMillis,
        easyMemosAmount,
        mediumMemosAmount,
        hardMemosAmount,
        memoryStability,
      ];
}
