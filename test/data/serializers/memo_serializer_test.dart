import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_serializer.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/enums/memo_difficulty.dart';
import 'package:memo/domain/models/memo.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/domain/models/memo_execution.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = MemoSerializer();
  final testMemo = Memo(
    id: '1',
    collectionId: '1',
    question: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string question')],
    answer: [MemoBlock(type: MemoBlockType.text, rawContents: 'This is my simple string answer')],
  );

  test('MemoSerializer should correctly encode/decode a Memo', () {
    final rawMemo = fixtures.memo();

    final decodedMemo = serializer.from(rawMemo);
    expect(decodedMemo, testMemo);

    final encodedMemo = serializer.to(decodedMemo);
    expect(encodedMemo, rawMemo);
  });

  test('MemoSerializer should fail to decode without required properties', () {
    expect(() {
      final rawMemo = fixtures.memo()..remove('id');
      serializer.from(rawMemo);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawMemo = fixtures.memo()..remove('collectionId');
      serializer.from(rawMemo);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawMemo = fixtures.memo()..remove('question');
      serializer.from(rawMemo);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawMemo = fixtures.memo()..remove('answer');
      serializer.from(rawMemo);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawMemo = fixtures.memo()..remove('executionsAmount');
      serializer.from(rawMemo);
    }, throwsA(isA<TypeError>()));
  });

  test('MemoSerializer should decode with optional properties', () {
    final rawMemo = fixtures.memo()
      ..['executionsAmount'] = 5
      ..['lastExecution'] = fixtures.memoExecution() // Use the existing `MemoExecution` fixture
      ..['dueDate'] = 1616757292509; // Fake date in millis

    final decodedMemo = serializer.from(rawMemo);

    final allPropsMemo = Memo(
      id: testMemo.id,
      collectionId: testMemo.collectionId,
      question: testMemo.question,
      answer: testMemo.answer,
      executionsAmount: 5,
      lastExecution: MemoExecution(
        started: DateTime.fromMillisecondsSinceEpoch(1616747007347, isUtc: true),
        finished: DateTime.fromMillisecondsSinceEpoch(1616747027347, isUtc: true),
        question: testMemo.question,
        answer: testMemo.answer,
        answeredDifficulty: MemoDifficulty.medium,
      ),
      dueDate: DateTime.fromMillisecondsSinceEpoch(1616757292509, isUtc: true),
    );

    expect(decodedMemo, allPropsMemo);
  });
}
