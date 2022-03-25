import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/memo_collection_metadata_serializer.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';

import '../../fixtures/fixtures.dart' as fixtures;
import '../../utils/fakes.dart' as fakes;

void main() {
  final serializer = MemoCollectionMetadataSerializer();
  final testMemo = MemoCollectionMetadata(
    uniqueId: '1',
    rawQuestion: fakes.question,
    rawAnswer: fakes.answer,
  );

  test('MemoCollectionMetadataSerializer should correctly encode/decode a MemoCollectionMetadata', () {
    final rawMemo = fixtures.memoCollectionMetadata();

    final decodedMemo = serializer.from(rawMemo);
    expect(decodedMemo, testMemo);

    final encodedMemo = serializer.to(decodedMemo);
    expect(encodedMemo, rawMemo);
  });

  test('MemoCollectionMetadataSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawMemo = fixtures.memoCollectionMetadata()..remove(MemoCollectionMetadataKeys.uniqueId);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );

    expect(
      () {
        final rawMemo = fixtures.memoCollectionMetadata()..remove(MemoCollectionMetadataKeys.rawQuestion);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );

    expect(
      () {
        final rawMemo = fixtures.memoCollectionMetadata()..remove(MemoCollectionMetadataKeys.rawAnswer);
        serializer.from(rawMemo);
      },
      throwsA(isA<TypeError>()),
    );
  });
}
