import 'package:memo/data/database_repository.dart';
import 'package:memo/domain/models/deck.dart';

class DeckSerializer implements JsonSerializer<Deck> {
  @override
  Deck fromMap(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final name = json['name'] as String;
    final description = json['description'] as String;
    final category = json['category'] as String;

    final rawTags = json['tags'] as List;
    // Casting just to make sure, because sembast returns an ImmutableList<dynamic>
    final tags = rawTags.cast<String>();

    final timeSpentInMillis = json['timeSpentInMillis'] as int;
    final easyCardsAmount = json['easyCardsAmount'] as int;
    final mediumCardsAmount = json['mediumCardsAmount'] as int;
    final hardCardsAmount = json['hardCardsAmount'] as int;

    return Deck(
      id: id,
      name: name,
      description: description,
      category: category,
      tags: tags,
      timeSpentInMillis: timeSpentInMillis,
      easyCardsAmount: easyCardsAmount,
      mediumCardsAmount: mediumCardsAmount,
      hardCardsAmount: hardCardsAmount,
    );
  }

  @override
  Map<String, dynamic> mapOf(Deck deck) => <String, dynamic>{
        'id': deck.id,
        'name': deck.name,
        'description': deck.description,
        'category': deck.category,
        'tags': deck.tags,
        'timeSpentInMillis': deck.timeSpentInMillis,
        'easyCardsAmount': deck.easyCardsAmount,
        'mediumCardsAmount': deck.mediumCardsAmount,
        'hardCardsAmount': deck.hardCardsAmount,
      };
}
