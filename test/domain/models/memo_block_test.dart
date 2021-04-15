import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/enums/memo_block_type.dart';
import 'package:memo/domain/models/memo_block.dart';

void main() {
  test('MemoBlock should not allow empty contents', () {
    expect(
      () {
        MemoBlock(type: MemoBlockType.text, rawContents: '');
      },
      throwsAssertionError,
    );
  });
}
