import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/models/memo_block.dart';
import 'package:memo/data/serializers/memo_block_serializer.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = MemoBlockSerializer();

  final testBlock = MemoBlock(type: MemoBlockType.text, rawContents: 'Raw text');

  test('MemoBlockSerializer should correctly encode/decode a MemoBlock', () {
    final rawBlock = fixtures.memoBlock();

    final decodedBlock = serializer.from(rawBlock);
    expect(decodedBlock, testBlock);

    final encodedBlock = serializer.to(decodedBlock);
    expect(encodedBlock, rawBlock);
  });

  test('MemoBlockSerializer should fail to decode without required properties', () {
    expect(() {
      final rawBlock = fixtures.memoBlock()..remove('type');
      serializer.from(rawBlock);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawBlock = fixtures.memoBlock()..remove('rawContents');
      serializer.from(rawBlock);
    }, throwsA(isA<TypeError>()));
  });
}
