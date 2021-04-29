import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../utils/fakes.dart' as fakes;

class FakeExecutionsMetadata extends MemoExecutionsMetadata {
  FakeExecutionsMetadata(int timeSpentInMillis, Map<MemoDifficulty, int> executionsAmounts)
      : super(timeSpentInMillis, executionsAmounts);
}

void main() {
  group('MemoExecution -', () {
    final started = DateTime.now();

    MemoExecution newExecution({
      DateTime? finished,
      List<Map<String, dynamic>>? rawQuestion,
      List<Map<String, dynamic>>? rawAnswer,
    }) {
      return MemoExecution(
        uniqueId: '1',
        collectionId: '1',
        started: started,
        finished: finished ?? started.add(const Duration(seconds: 1)),
        rawQuestion: rawQuestion ?? fakes.question,
        rawAnswer: rawAnswer ?? fakes.answer,
        markedDifficulty: MemoDifficulty.easy,
      );
    }

    test('should not allow a missing question', () {
      expect(
        () {
          newExecution(rawQuestion: []);
        },
        throwsAssertionError,
      );

      expect(
        () {
          newExecution(rawQuestion: [<String, dynamic>{}]);
        },
        throwsAssertionError,
      );
    });

    test('should not allow a missing answer', () {
      expect(
        () {
          newExecution(rawAnswer: []);
        },
        throwsAssertionError,
      );

      expect(
        () {
          newExecution(rawAnswer: [<String, dynamic>{}]);
        },
        throwsAssertionError,
      );
    });
    test('should not allow finished to be before started', () {
      expect(
        () {
          newExecution(finished: started.subtract(const Duration(seconds: 1)));
        },
        throwsAssertionError,
      );
    });
  });

  test('MemoExecutionsMetadata should not allow execution properties be inconsistent', () {
    expect(
      () {
        FakeExecutionsMetadata(1, const {});
      },
      throwsAssertionError,
    );

    expect(
      () {
        FakeExecutionsMetadata(0, const {MemoDifficulty.easy: 1});
      },
      throwsAssertionError,
    );
  });
}
