import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/models/card_block.dart';
import 'package:memo/domain/serializers/card_block_serializer.dart';

import '../../fixtures/fixtures.dart' as fixtures;

void main() {
  final serializer = CardBlockSerializer();

  final testBlock = CardBlock(type: CardBlockType.text, rawContents: 'Raw text');

  test('CardBlockSerializer should correctly encode/decode a CardBlock', () {
    final rawBlock = fixtures.cardBlock();

    final decodedBlock = serializer.fromMap(rawBlock);
    expect(decodedBlock, testBlock);

    final encodedBlock = serializer.mapOf(decodedBlock);
    expect(encodedBlock, rawBlock);
  });

  test('CardBlockSerializer should fail to decode without required properties', () {
    expect(() {
      final rawBlock = fixtures.cardBlock()..remove('type');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));

    expect(() {
      final rawBlock = fixtures.cardBlock()..remove('rawContents');
      serializer.fromMap(rawBlock);
    }, throwsA(isA<TypeError>()));
  });
}
