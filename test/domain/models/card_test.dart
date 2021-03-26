import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/enums/card_difficulty.dart';
import 'package:memo/domain/models/card.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/models/card_execution.dart';

void main() {
  test('Card should fail assert when executionsAmount is not a valid integer', () {
    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string answer')],
          executionsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });

  test('Card should fail assert when question/answer are not present', () {
    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: const [],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string answer')],
          executionsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: const [],
          executionsAmount: -1,
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });

  test('Card should fail assert when lastExecution and executionsAmount are not in sync', () {
    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          executionsAmount: 1,
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          lastExecution: CardExecution(
            started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
            finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
            question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
            answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
            answeredDifficulty: CardDifficulty.medium,
          ),
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });

  test('Card should fail assert when lastExecution and dueDate are not in sync', () {
    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          executionsAmount: 1,
          lastExecution: CardExecution(
            started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
            finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
            question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
            answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
            answeredDifficulty: CardDifficulty.medium,
          ),
        );
      },
      throwsA(isA<AssertionError>()),
    );

    expect(
      () {
        Card(
          id: '1',
          deckId: '1',
          question: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          answer: [CardBlock(type: CardBlockType.text, rawContents: 'This is my simple string question')],
          dueDate: DateTime.now(),
        );
      },
      throwsA(isA<AssertionError>()),
    );
  });
}
