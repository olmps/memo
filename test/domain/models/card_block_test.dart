import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/card_block_type.dart';
import 'package:memo/domain/models/card_block.dart';

void main() {
  test('CardBlock should not allow empty contents', () {
    expect(
      () {
        CardBlock(type: CardBlockType.text, rawContents: '');
      },
      throwsA(isA<AssertionError>()),
    );
  });
}
