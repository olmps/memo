import 'package:flutter_test/flutter_test.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

import '../../utils/fakes.dart' as fakes;

void main() {
  test('should not allow a missing question', () {
    expect(
      () {
        MemoCollectionMetadata(uniqueId: '1', rawQuestion: [], rawAnswer: fakes.answer);
      },
      throwsAssertionError,
    );

    expect(
      () {
        MemoCollectionMetadata(uniqueId: '1', rawQuestion: [<String, dynamic>{}], rawAnswer: fakes.answer);
      },
      throwsAssertionError,
    );
  });

  test('should not allow a missing answer', () {
    expect(
      () {
        MemoCollectionMetadata(uniqueId: '1', rawQuestion: fakes.question, rawAnswer: []);
      },
      throwsAssertionError,
    );

    expect(
      () {
        MemoCollectionMetadata(uniqueId: '1', rawQuestion: fakes.question, rawAnswer: [<String, dynamic>{}]);
      },
      throwsAssertionError,
    );
  });
}
