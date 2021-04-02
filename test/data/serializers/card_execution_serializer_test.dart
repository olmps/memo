import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/card_execution_serializer.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/models/card_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final testExecution = CardExecution(
    started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
    finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
    question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
    answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string answer')],
    answeredDifficulty: CardDifficulty.medium,
  );

  group('CardExecutionSerializer -', () {
    final serializer = CardExecutionSerializer();

    test('CardExecutionSerializer should correctly encode/decode a CardExecution', () {
      final rawExecution = fixtures.cardExecution();

      final decodedExecution = serializer.from(rawExecution);
      expect(decodedExecution, testExecution);

      final encodedExecution = serializer.to(decodedExecution);
      expect(encodedExecution, rawExecution);
    });

    test('CardExecutionSerializer should fail to decode without required properties', () {
      expect(() {
        final rawExecution = fixtures.cardExecution()..remove('started');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.cardExecution()..remove('finished');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.cardExecution()..remove('question');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.cardExecution()..remove('answer');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.cardExecution()..remove('answeredDifficulty');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
    });
  });

  group('CardExecutionsSerializer -', () {
    final serializer = CardExecutionsSerializer();
    Map<String, Object> createRawExecutions() => {
          'cardId': '1',
          'deckId': '1',
          'executions': [fixtures.cardExecution()],
        };

    final testExecutions = CardExecutions(cardId: '1', deckId: '1', executions: [testExecution]);

    test('CardExecutionsSerializer should correctly encode/decode a CardExecutions', () {
      final rawExecutions = createRawExecutions();

      final decodedExecutions = serializer.from(rawExecutions);
      expect(decodedExecutions, testExecutions);

      final encodedExecution = serializer.to(decodedExecutions);
      expect(encodedExecution, rawExecutions);
    });

    test('CardExecutionsSerializer should fail to decode without required properties', () {
      expect(() {
        final rawExecutions = createRawExecutions()..remove('cardId');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecutions = createRawExecutions()..remove('deckId');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecutions = createRawExecutions()..remove('executions');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
    });
  });
}
