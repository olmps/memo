import 'package:memo/data/database_repository.dart';
import 'package:meta/meta.dart';

@immutable
class Deck extends KeyStorable {
  const Deck({
    required String id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    this.timeSpentInMillis = 0,
    this.easyCardsAmount = 0,
    this.mediumCardsAmount = 0,
    this.hardCardsAmount = 0,
  })  : assert(timeSpentInMillis >= 0, 'timeSpentInMillis must be a positive (or zero) integer'),
        assert(easyCardsAmount >= 0, 'easyCardsAmount must be a positive (or zero) integer'),
        assert(mediumCardsAmount >= 0, 'mediumCardsAmount must be a positive (or zero) integer'),
        assert(hardCardsAmount >= 0, 'hardCardsAmount must be a positive (or zero) integer'),
        super(id: id);

  final String name;
  final String description;
  final String category;

  /// List of tags that can associate with this [Resource]
  ///
  /// This is useful in cases where we must match a `Deck.tags` with each available resources
  final List<String> tags;

  /// The total amount of time spent executing `Card`s for this deck (in milliseconds)
  final int timeSpentInMillis;

  /// The total amount of easy answers (`CardDifficulty`) for this deck
  final int easyCardsAmount;

  /// The total amount of medium answers (`CardDifficulty`) for this deck
  final int mediumCardsAmount;

  /// The total amount of hard answers (`CardDifficulty`) for this deck
  final int hardCardsAmount;

  /// `true` if this [Deck] has never executed any `Card`
  bool get isPristine => timeSpentInMillis == 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        tags,
        timeSpentInMillis,
        easyCardsAmount,
        mediumCardsAmount,
        hardCardsAmount,
      ];
}
