import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../utils/fakes.dart' as fakes;

void main() {
  Memo newMemo({
    List<Map<String, dynamic>>? rawQuestion,
    List<Map<String, dynamic>>? rawAnswer,
    int timeSpentInMillis = 0,
    MemoExecution? lastExecution,
  }) {
    return Memo(
      uniqueId: 'id',
      collectionId: 'collectionId',
      rawQuestion: rawQuestion ?? fakes.question,
      rawAnswer: rawAnswer ?? fakes.answer,
      timeSpentInMillis: timeSpentInMillis,
      lastExecution: lastExecution,
    );
  }

  test('Memo should not allow incoherent execution-related properties', () {
    expect(
      () {
        newMemo(timeSpentInMillis: 1);
      },
      throwsAssertionError,
    );

    expect(
      () {
        newMemo(
          lastExecution: MemoExecution(
            uniqueId: '1',
            collectionId: '1',
            started: DateTime.now(),
            finished: DateTime.now().subtract(const Duration(seconds: 1)),
            rawQuestion: fakes.question,
            rawAnswer: fakes.answer,
            markedDifficulty: MemoDifficulty.easy,
          ),
        );
      },
      throwsAssertionError,
    );
  });
}
