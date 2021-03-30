import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/models/card_execution.dart';

void main() {
  final started = DateTime.now();
  final question = [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')];
  final answer = [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string answer')];

  test('CardExecution should not allow empty question/answer', () {
    expect(
      () {
        CardExecution(
          started: started,
          finished: started.add(const Duration(seconds: 1)),
          question: question,
          answer: const [],
          answeredDifficulty: CardDifficulty.easy,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        CardExecution(
          started: started,
          finished: started.add(const Duration(seconds: 1)),
          question: const [],
          answer: answer,
          answeredDifficulty: CardDifficulty.easy,
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });

  test('CardExecution should not allow finished to be before started', () {
    expect(
      () {
        CardExecution(
          started: started.add(const Duration(seconds: 1)),
          finished: started,
          question: question,
          answer: answer,
          answeredDifficulty: CardDifficulty.easy,
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });

  test('CardExecutions should not allow empty executions', () {
    expect(
      () {
        CardExecutions(cardId: 'cardId', deckId: 'deckId', executions: const []);
      },
      throwsA(isA<AssertionError>()),
    );
  });
}
