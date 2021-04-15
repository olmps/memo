import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/domain/models/memo_execution.dart';

void main() {
  final started = DateTime.now();
  final question = [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')];
  final answer = [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string answer')];

  test('MemoExecution should not allow empty question/answer', () {
    expect(
      () {
        MemoExecution(
          started: started,
          finished: started.add(const Duration(seconds: 1)),
          question: question,
          answer: const [],
          answeredDifficulty: MemoDifficulty.easy,
        );
      },
      throwsAssertionError,
    );

    expect(
      () {
        MemoExecution(
          started: started,
          finished: started.add(const Duration(seconds: 1)),
          question: const [],
          answer: answer,
          answeredDifficulty: MemoDifficulty.easy,
        );
      },
      throwsAssertionError,
    );
  });

  test('MemoExecution should not allow finished to be before started', () {
    expect(
      () {
        MemoExecution(
          started: started.add(const Duration(seconds: 1)),
          finished: started,
          question: question,
          answer: answer,
          answeredDifficulty: MemoDifficulty.easy,
        );
      },
      throwsAssertionError,
    );
  });

  test('MemoExecution should not allow empty executions', () {
    expect(
      () {
        MemoExecutions(memoId: 'memoId', collectionId: 'collectionId', executions: const []);
      },
      throwsAssertionError,
    );
  });
}
