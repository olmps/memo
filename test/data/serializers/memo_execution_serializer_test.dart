import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;
import '../../utils/fakes.dart' as fakes;

void main() {
  final testExecution = MemoExecution(
    uniqueId: '1',
    collectionId: '1',
    started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
    finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
    rawAnswer: fakes.answer,
    rawQuestion: fakes.question,
    markedDifficulty: MemoDifficulty.easy,
  );

  group('MemoExecutionSerializer -', () {
    final serializer = MemoExecutionSerializer();

    test('should correctly encode/decode a MemoExecution', () {
      final rawExecution = fixtures.memoExecution();

      final decodedExecution = serializer.from(rawExecution);
      expect(decodedExecution, testExecution);

      final encodedExecution = serializer.to(decodedExecution);
      expect(encodedExecution, rawExecution);
    });

    test('should fail to decode without required properties', () {
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.uniqueId);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.collectionId);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.started);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.finished);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.rawQuestion);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.rawAnswer);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
      expect(
        () {
          final rawExecution = fixtures.memoExecution()..remove(MemoExecutionKeys.markedDifficulty);
          serializer.from(rawExecution);
        },
        throwsA(isA<TypeError>()),
      );
    });
  });
}
