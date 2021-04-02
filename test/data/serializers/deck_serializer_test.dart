import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/deck_serializer.dart';
import 'package:memo/domain/models/deck.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = DeckSerializer();
  const testDeck = Deck(
    id: '1',
    name: 'My Deck',
    description: 'This deck represents a deck.',
    category: 'Category',
    tags: ['Tag 1', 'Tag 2'],
  );

  test('DeckSerializer should correctly encode/decode a Deck', () {
    final rawDeck = fixtures.deck();

    final decodedDeck = serializer.from(rawDeck);
    expect(decodedDeck, testDeck);

    final encodedDeck = serializer.to(decodedDeck);
    expect(encodedDeck, rawDeck);
  });

  test('DeckSerializer should fail to decode without required properties', () {
    expect(() {
      final rawDeck = fixtures.deck()..remove('id');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('name');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('description');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('category');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('tags');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('timeSpentInMillis');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('easyCardsAmount');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('mediumCardsAmount');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawDeck = fixtures.deck()..remove('hardCardsAmount');
      serializer.from(rawDeck);
    }, throwsA(isA<TypeError>()));
  });
}
