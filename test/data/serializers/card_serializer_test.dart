import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/card_serializer.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/models/card_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = CardSerializer();
  final testCard = Card(
    id: '1',
    deckId: '1',
    question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
    answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string answer')],
  );

  test('CardSerializer should correctly encode/decode a Card', () {
    final rawCard = fixtures.card();

    final decodedCard = serializer.from(rawCard);
    expect(decodedCard, testCard);

    final encodedCard = serializer.to(decodedCard);
    expect(encodedCard, rawCard);
  });

  test('CardSerializer should fail to decode without required properties', () {
    expect(() {
      final rawCard = fixtures.card()..remove('id');
      serializer.from(rawCard);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawCard = fixtures.card()..remove('deckId');
      serializer.from(rawCard);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawCard = fixtures.card()..remove('question');
      serializer.from(rawCard);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawCard = fixtures.card()..remove('answer');
      serializer.from(rawCard);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawCard = fixtures.card()..remove('executionsAmount');
      serializer.from(rawCard);
    }, throwsA(isA<TypeError>()));
  });

  test('CardSerializer should decode with optional properties', () {
    final rawCard = fixtures.card()
      ..['executionsAmount'] = 5
      ..['lastExecution'] = fixtures.cardExecution() // Use the existing `CardExecution` fixture
      ..['dueDate'] = 1616757292509; // Fake date in millis

    final decodedCard = serializer.from(rawCard);

    final allPropsCard = Card(
      id: testCard.id,
      deckId: testCard.deckId,
      question: testCard.question,
      answer: testCard.answer,
      executionsAmount: 5,
      lastExecution: CardExecution(
        started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
        finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
        question: testCard.question,
        answer: testCard.answer,
        answeredDifficulty: CardDifficulty.medium,
      ),
      dueDate: DateTime.fromMillisecondsSinceEpoch(1616757292509, isUtc: true),
    );

    expect(decodedCard, allPropsCard);
  });
}
