import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_execution_serializer.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final testExecution = MemoExecution(
    started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
    finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
    question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
    answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string answer')],
    answeredDifficulty: MemoDifficulty.medium,
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
      expect(() {
        final rawExecution = fixtures.memoExecution()..remove('started');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.memoExecution()..remove('finished');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.memoExecution()..remove('question');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.memoExecution()..remove('answer');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecution = fixtures.memoExecution()..remove('answeredDifficulty');
        serializer.from(rawExecution);
      }, throwsA(isA<TypeError>()));
    });
  });

  group('MemoExecutionsSerializer -', () {
    final serializer = MemoExecutionsSerializer();
    Map<String, Object> createRawExecutions() => {
          'memoId': '1',
          'collectionId': '1',
          'executions': [fixtures.memoExecution()],
        };

    final testExecutions = MemoExecutions(memoId: '1', collectionId: '1', executions: [testExecution]);

    test('should correctly encode/decode a MemoExecutions', () {
      final rawExecutions = createRawExecutions();

      final decodedExecutions = serializer.from(rawExecutions);
      expect(decodedExecutions, testExecutions);

      final encodedExecution = serializer.to(decodedExecutions);
      expect(encodedExecution, rawExecutions);
    });

    test('should fail to decode without required properties', () {
      expect(() {
        final rawExecutions = createRawExecutions()..remove('memoId');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecutions = createRawExecutions()..remove('collectionId');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
      expect(() {
        final rawExecutions = createRawExecutions()..remove('executions');
        serializer.from(rawExecutions);
      }, throwsA(isA<TypeError>()));
    });
  });
}
