import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/collection_memos_serializer.dart';
import 'package:memo/domain/models/collection.dart';
import 'package:memo/domain/models/memo_collection_metadata.dart';
import 'package:memo/domain/transients/collection_memos.dart';

import '../../fixtures/fixtures.dart' as fixtures;
import '../../utils/fakes.dart' as fakes;

void main() {
  final serializer = CollectionMemosSerializer();
  final testCollection = CollectionMemos(
    id: '1',
    name: 'My Collection',
    description: 'This collection represents a collection.',
    category: 'Category',
    tags: const ['Tag 1', 'Tag 2'],
    contributors: [const Contributor(name: 'name')],
    memosMetadata: [
      MemoCollectionMetadata(
        uniqueId: '1',
        rawQuestion: fakes.question,
        rawAnswer: fakes.answer,
      )
    ],
  );

  Map<String, dynamic> completeFixture() => fixtures.collectionMemos()
    ..[CollectionMemosKeys.memosMetadata] = [fixtures.memoCollectionMetadata()]
    ..[CollectionMemosKeys.contributors] = [fixtures.contributor()];

  test('CollectionMemosSerializer should correctly encode/decode a CollectionMemos', () {
    final rawCollection = completeFixture();

    final decodedCollection = serializer.from(rawCollection);
    expect(decodedCollection, testCollection);

    final encodedCollection = serializer.to(decodedCollection);
    expect(encodedCollection, rawCollection);
  });

  test('CollectionMemosSerializer should fail to decode without required properties', () {
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.id);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.name);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.description);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.category);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.tags);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.contributors);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
    expect(
      () {
        final rawCollection = completeFixture()..remove(CollectionMemosKeys.memosMetadata);
        serializer.from(rawCollection);
      },
      throwsA(isA<TypeError>()),
    );
  });
}
