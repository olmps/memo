import 'package:flutter_test/flutter_test.dart';
import 'package:memo/data/serializers/collection_memos_serializer.dart';
import 'package:memo/domain/models/contributor.dart';
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
    contributors: [
      const Contributor(
        id: '03a5f9b4-b424-4010-8027-1ef22c748g56',
        name: '@lucasbiancogs',
        imageUrl: 'https://avatars.githubusercontent.com/u/64819163?s=400&u=3ca78fee7808f7b5b7ad8e9230e268519e9aea71&v=4',
        url: 'https://github.com/lucasbiancogs'
      )
    ],
    memosMetadata: [
      MemoCollectionMetadata(
        uniqueId: '1',
        rawQuestion: fakes.question,
        rawAnswer: fakes.answer,
      )
    ],
  );

  Map<String, dynamic> fixtureWithMemos() =>
      fixtures.collectionMemos()..[CollectionMemosKeys.memosMetadata] = [fixtures.memoCollectionMetadata()];

  test('CollectionMemosSerializer should correctly encode/decode a CollectionMemos', () {
    final rawCollection = fixtureWithMemos();

    final decodedCollection = serializer.from(rawCollection);
    expect(decodedCollection, testCollection);

    final encodedCollection = serializer.to(decodedCollection);
    expect(encodedCollection, rawCollection);
  });

  test('CollectionMemosSerializer should fail to decode without required properties', () {
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.id);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.name);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.description);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.category);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.tags);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
    expect(() {
      final rawCollection = fixtureWithMemos()..remove(CollectionMemosKeys.memosMetadata);
      serializer.from(rawCollection);
    }, throwsA(isA<TypeError>()));
  });
}
