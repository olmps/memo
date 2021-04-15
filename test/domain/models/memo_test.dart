import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/domain/models/memo_execution.dart';

void main() {
  test('Memo should fail assert when executionsAmount is not a valid integer', () {
    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string answer')],
          executionsAmount: -1,
        );
      },
      throwsAssertionError,
    );
  });

  test('Memo should fail assert when question/answer are not present', () {
    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: const [],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string answer')],
          executionsAmount: -1,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: const [],
          executionsAmount: -1,
        );
      },
      throwsAssertionError,
    );
  });

  test('Memo should fail assert when lastExecution and executionsAmount are not in sync', () {
    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          executionsAmount: 1,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          lastExecution: MemoExecution(
            started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
            finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
            question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
            answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
            answeredDifficulty: MemoDifficulty.medium,
          ),
        );
      },
      throwsAssertionError,
    );
  });

  test('Memo should fail assert when lastExecution and dueDate are not in sync', () {
    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          executionsAmount: 1,
          lastExecution: MemoExecution(
            started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
            finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
            question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
            answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
            answeredDifficulty: MemoDifficulty.medium,
          ),
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        Memo(
          id: '1',
          collectionId: '1',
          question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
          dueDate: DateTime.now(),
        );
      },
      throwsAssertionError,
    );
  });
}
