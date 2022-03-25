import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_difficulty_parser.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;
import '../../utils/fakes.dart' as fakes;

void main() {
  final serializer = MemoSerializer();
  final testMemo = Memo(
    uniqueId: '1',
    collectionId: '1',
    rawQuestion: fakes.question,
    rawAnswer: fakes.answer,
  );

  test('MemoSerializer should correctly encode/decode a Memo', () {
    final rawMemo = fixtures.memo();

    final decodedMemo = serializer.from(rawMemo);
    expect(decodedMemo, testMemo);

    final encodedMemo = serializer.to(decodedMemo);
    expect(encodedMemo, rawMemo);
  });

  test('MemoSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawMemo = fixtures.memo()..remove(MemoKeys.uniqueId);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );

    expect(
      () {
        final rawMemo = fixtures.memo()..remove(MemoKeys.collectionId);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );

    expect(
      () {
        final rawMemo = fixtures.memo()..remove(MemoKeys.rawQuestion);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );

    expect(
      () {
        final rawMemo = fixtures.memo()..remove(MemoKeys.rawAnswer);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );
  });

  test('MemoSerializer should decode with optional properties', () {
    final rawMemo = fixtures.memo()
      ..[MemoKeys.executionsAmounts] = {
        MemoDifficulty.easy.raw: 1,
        MemoDifficulty.medium.raw: 0,
        MemoDifficulty.hard.raw: 0
      }
      ..[MemoKeys.timeSpentInMillis] = 5000
      ..[MemoKeys.lastExecution] = fixtures.memoExecution(); // Use the existing `MemoExecution` fixture

    final decodedMemo = serializer.from(rawMemo);

    final testExecution = MemoExecution(
      uniqueId: '1',
      collectionId: '1',
      started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
      finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
      rawAnswer: fakes.answer,
      rawQuestion: fakes.question,
      markedDifficulty: MemoDifficulty.easy,
    );

    final allPropsMemo = Memo(
      uniqueId: testMemo.uniqueId,
      collectionId: testMemo.collectionId,
      rawQuestion: testMemo.rawQuestion,
      rawAnswer: testMemo.rawAnswer,
      executionsAmounts: const {MemoDifficulty.easy: 1},
      timeSpentInMillis: 5000,
      lastExecution: testExecution,
    );

    expect(decodedMemo, allPropsMemo);
    expect(rawMemo, serializer.to(decodedMemo));
  });
}
